// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.17;

import "../../precompiles/Staking.sol";

contract StakingManager {
    string[] private stakingMethods = [MSG_DELEGATE, MSG_UNDELEGATE, MSG_REDELEGATE, MSG_CANCEL_UNDELEGATION];

    /// @dev Approves all staking transactions with the maximum amount of tokens.
    /// @dev This creates a Cosmos Authorization Grant for the given methods.
    /// @dev This emits an Approval event.
    function approveAllStakingMethodsWithMaxAmount() public {
        bool success = STAKING_CONTRACT.approve(msg.sender, type(uint256).max, stakingMethods);
        require(success, "Failed to approve staking methods");
    }

    /// @dev Approves a list of Cosmos staking transactions with a specific amount of tokens denominated in aevmos.
    /// @dev This creates a Cosmos Authorization Grant for the given methods.
    /// @dev This emits an Approval event.
    /// @param _methods The message type URLs of the methods to approve.
    /// @param _amount The amount of tokens approved to be spent in aevmos.
    function approveStakingMethods(string[] calldata _methods, uint256 _amount) public {
        bool success = STAKING_CONTRACT.approve(msg.sender, _amount, _methods);
        require(success, "Failed to approve staking methods");
    }

    /// @dev Returns the remaining number of tokens that spender will be allowed to spend
    /// on behalf of the owner through staking. This is zero by default.
    /// @return remaining The remaining number of tokens available to be spent in aevmos.
    function getAllowance() public view returns (uint256 remaining) {
        return STAKING_CONTRACT.allowance(address(this), msg.sender, MSG_DELEGATE);
    }

    /// @dev stake a given amount of tokens. Returns the completion time of the staking transaction.
    /// @dev This emits an Delegate event.
    /// @param _validatorAddr The address of the validator.
    /// @param _amount The amount of tokens to stake in aevmos.
    /// @return completionTime The completion time of the staking transaction.
    function stakeTokens(string memory _validatorAddr, uint256 _amount) public returns (int64 completionTime) {
        return STAKING_CONTRACT.delegate(msg.sender, _validatorAddr, _amount);
    }

    /// @dev redelegate a given amount of tokens. Returns the completion time of the redelegate transaction.
    /// @dev This emits a Redelegate event.
    /// @param _validatorSrcAddr The address of the source validator.
    /// @param _validatorDstAddr The address of the destination validator.
    /// @param _amount The amount of tokens to redelegate in aevmos.
    /// @return completionTime The completion time of the redelegate transaction.
    function redelegateTokens(string memory _validatorSrcAddr, string memory _validatorDstAddr, uint256 _amount) public returns (int64 completionTime) {
        return STAKING_CONTRACT.redelegate(msg.sender, _validatorSrcAddr, _validatorDstAddr, _amount);
    }

    /// @dev unstake a given amount of tokens. Returns the completion time of the unstaking transaction.
    /// @dev This emits an Undelegate event.
    /// @param _validatorAddr The address of the validator.
    /// @param _amount The amount of tokens to unstake in aevmos.
    /// @return completionTime The completion time of the unstaking transaction.
    function unstakeTokens(string memory _validatorAddr, uint256 _amount) public returns (int64 completionTime) {
        return STAKING_CONTRACT.undelegate(msg.sender, _validatorAddr, _amount);
    }

    /// @dev cancel an unbonding delegation. Returns the completion time of the unbonding delegation cancellation transaction.
    /// @dev This emits an CancelUnbondingDelegation event.
    /// @param _validatorAddr The address of the validator.
    /// @param _amount The amount of tokens to cancel the unbonding delegation in aevmos.
    /// @param _creationHeight The creation height of the unbonding delegation.
    function cancelUnbondingDelegation(string memory _validatorAddr, uint256 _amount, uint256 _creationHeight) public returns (int64 completionTime) {
        return STAKING_CONTRACT.cancelUnbondingDelegation(msg.sender, _validatorAddr, _amount, _creationHeight);
    }

    /// @dev Returns the delegation information for a given validator for the msg sender.
    /// @param _validatorAddr The address of the validator.
    /// @return shares and balance. The delegation information for a given validator for the msg sender.
    function getDelegation(string memory _validatorAddr) public view returns (uint256 shares, Coin memory balance) {
        return STAKING_CONTRACT.delegation(msg.sender, _validatorAddr);
    }

    /// @dev Returns the unbonding delegation information for a given validator for the msg sender.
    /// @param _validatorAddr The address of the validator.
    /// @return entries The unbonding delegation entries for a given validator for the msg sender.
    function getUnbondingDelegation(string memory _validatorAddr) public view returns (UnbondingDelegationEntry[] memory entries) {
        return STAKING_CONTRACT.unbondingDelegation(msg.sender, _validatorAddr);
    }
}
