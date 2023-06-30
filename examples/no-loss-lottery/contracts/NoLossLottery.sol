// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.18;

import "../../../precompiles/stateful/Staking.sol";
import "../../../precompiles/stateful/Distribution.sol";

contract NoLossLottery {

    /// @dev A struct that keeps track of the winners for each round.
    struct Winner {
        uint16 round;
        uint256 winningNumber;
        address winnerAddress;
        uint256 winingAmount;
        uint256 timestamp;
    }

    /// @dev A struct that keeps track of the unbonding delegations.
    struct UnbondingRequest {
        int64 completionTime;
        uint256 amount;
    }

    /// @dev the required authorizations for Staking and Distribution
    string[] private stakingMethods = [MSG_DELEGATE, MSG_UNDELEGATE, MSG_REDELEGATE];
    string[] private distributionMethods = [MSG_WITHDRAW_DELEGATOR_REWARD];
    /// @dev map to keep track of user deposits to the contract.
    mapping(address => uint256) public deposits;
    /// @dev map to keep track of the delegation amounts for a user.
    mapping(address => uint256) public delegations;
    /// @dev map that keeps track of winnings
    mapping(address => uint256) public winnings;
    /// @dev map that keeps track of all currently unbonding delegations
    mapping(address => UnbondingRequest) public unbondingDelegations;
    /// @dev the total amount staked.
    uint256 public totalStaked;
    /// @dev the totalStaked amount converted to total number of tickets.
    uint256 public totalTickets;
    /// @dev array of addresses for each user that has entered the lottery.
    address[] public participants;
    /// @dev map to keep track of addresses that have entered the lottery.
    mapping(address => bool) private addressExists;
    /// @dev the winners array stores all historical winners.
    Winner[] public winners;

    /// @dev events emitted by the contract.
    event Deposit(address indexed _from, uint256 _value);
    event Withdraw(address indexed _to, uint256 _value);
    event WithdrawWinnings(address indexed _to, uint256 _value);
    event EnterLottery(address indexed _from, uint256 _value);
    event ExitLottery(address indexed _to, uint256 _value);
    event PickWinner(address indexed _winner, uint256 _value);

    // Deposit into the contract
    function deposit() payable external {
        require(msg.value % 1 ether == 0, "Amount must be a whole number of Evmos");
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw deposits from contract
    function withdraw(uint256 _amount) public {
        uint256 ts = uint256(int256(unbondingDelegations[msg.sender].completionTime));
        require(block.timestamp >= ts, "The time has not passed yet");
        require(unbondingDelegations[msg.sender].amount > 0, "You have nothing to withdraw");
        deposits[msg.sender] += unbondingDelegations[msg.sender].amount;
        // Make sure that the sender has balance in our deposits map
        require(deposits[msg.sender] >= _amount, "Deposit amount larger than requested withdraw");
        // Transfer the requested amount of Evmos to the sender.
        (bool sent,) = payable(msg.sender).call{value: _amount}("");
        require(sent, "Failed to send Evmos");
        delete unbondingDelegations[msg.sender];
        emit Withdraw(msg.sender, _amount);
    }

    // Withdraw winnings from contract
    function withdrawWinnings() public {
        require(winnings[msg.sender] > 0, "You have no winnings yet");
        (bool sent,) = payable(msg.sender).call{value: winnings[msg.sender]}("");
        winnings[msg.sender] = 0;
        emit WithdrawWinnings(msg.sender, winnings[msg.sender]);
    }

    // Picks a winner for the lottery
    function pickWinner(string memory _validatorAddr) public {
        Coin[] memory newRewards = DISTRIBUTION_CONTRACT.withdrawDelegatorRewards(address(this), _validatorAddr);
        require(newRewards[0].amount > 0, "The rewards have not been distributed yet");

        // Used to ensure that the order of the participants array is not used to determine the winner.
        _shuffleParticipants();

        uint256 winnerIndex = getRandomNumber();
        uint256 currentSum = 0;
        address winner;

        for (uint256 i = 0; i < participants.length; i++) {
            currentSum += delegations[participants[i]] / 1e18;
            if (currentSum >= winnerIndex) {
                winner = participants[i];
                break;
            }
        }

        uint256 amountWon = newRewards[0].amount;
        winners.push(Winner(uint16(winners.length + 1), winnerIndex, winner, amountWon, block.timestamp));
        winnings[winner] += amountWon;
        emit PickWinner(winner, amountWon);
    }

    // Enters the lottery by delegating to a validator
    function enterLottery(string memory _validatorAddr, uint256 _amount) public {
        require(_amount % 1 ether == 0, "Amount must be a whole number of Evmos");
        require(_amount <= deposits[msg.sender], "This address does not hold a deposit amount with the lottery");
        _approveRequiredMsgs(_amount);
        STAKING_CONTRACT.delegate(address(this), _validatorAddr, _amount);
        delegations[msg.sender] += _amount;
        deposits[msg.sender] -= _amount;
        totalStaked += _amount;
        totalTickets += _amount / 1e18;
        /// make sure an address is pushed only once per prize period
        if (!addressExists[msg.sender]) {
            participants.push(msg.sender);
            addressExists[msg.sender] = true;
        }
        emit EnterLottery(msg.sender, _amount);
    }

    // Exits the lottery returning the funds back to deposits after the unbonding period
    function exitLottery(string memory _validatorAddr, uint256 _amount) public {
        require(_amount <= delegations[msg.sender], "This address does not hold a delegation amount with the lottery");
        require(_amount == delegations[msg.sender], "You must exit the entire delegation amount");
        int64 completionTime = STAKING_CONTRACT.undelegate(address(this), _validatorAddr, _amount);
        delegations[msg.sender] -= _amount;
        unbondingDelegations[msg.sender] = UnbondingRequest(completionTime, _amount);
        totalStaked -= _amount;
        deposits[msg.sender] += _amount;
        totalTickets -= _amount / 1e18;

        if (delegations[msg.sender] == 0) {
            for (uint256 i = 0; i < participants.length; i++) {
                if (participants[i] == msg.sender) {
                    participants[i] = participants[participants.length - 1];
                    participants.pop();
                    break;
                }
            }
        }

        emit ExitLottery(msg.sender, _amount);
    }


    // ------------------------------
    // VIEW FUNCTIONS
    // ------------------------------
    function getNumberOfRounds() public view returns (uint256){
        return winners.length;
    }

    function getRandomNumber() public view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number))) % totalTickets;
        return randomNumber;
    }

    function getContractRewards(string memory _validatorAddr) public view returns (DecCoin[] memory) {
        return DISTRIBUTION_CONTRACT.delegationRewards(address(this), _validatorAddr);
    }

    function getDelegation(address _sender, string memory _valAddr) public view returns (uint256, Coin memory) {
        return STAKING_CONTRACT.delegation(_sender, _valAddr);
    }

    function getUnbondingDelegation(string memory _validatorAddr) public view returns (UnbondingDelegationEntry[] memory) {
        return STAKING_CONTRACT.unbondingDelegation(address(this), _validatorAddr);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getCurrentParticipants() public view returns (address[] memory) {
        return participants;
    }

    // ------------------------------
    // HELPER FUNCTIONS
    // ------------------------------

    /// @dev returns a random number between 0 and the number of participants
    function _random() private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number))) % participants.length;
        return randomNumber;
    }

    /// @dev shuffles the participants array
    function _shuffleParticipants() private {
        for (uint256 i = participants.length - 1; i > 0; i--) {
            uint256 j = _random() % (i + 1);
            (participants[i], participants[j]) = (participants[j], participants[i]);
        }
    }

    /// @dev approves the staking and distribution contracts to spend the lottery's funds
    function _approveRequiredMsgs(uint256 _amount) internal {
        bool successStk = STAKING_CONTRACT.approve(address(this), _amount, stakingMethods);
        require(successStk, "Staking Approve failed");
    }

}
