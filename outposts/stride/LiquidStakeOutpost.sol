// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.17;

import "ICS20.sol";


contract LiquidStakeOutpost {

    // The constants for channel and port
    string private channel = "channel-25";
    string private port = "transfer";
    string private baseDenom = "aevmos";

    // Default allowed list is empty indicating no restrictions
    string[] private defaultAllowList = new string[](0);

    /// @dev Creates an approval allocation against the smart contract for IBC transfers.
    /// @param _amount The amount of the base denomination to be swapped
    /// @param _baseDenom The base denomination used for the swap, e.g. "aevmos" for Evmos mainnet
    function _approveTransfer(uint256 _amount, string memory _baseDenom) private {
        // Create the spend limit of coins, in this case only aevmos
        Coin[] memory spendLimit = new Coin[](1);
        spendLimit[0] = Coin(_baseDenom, _amount);
        // Create allocation for coins on the specified channel and port
        Allocation[] memory allocations = new Allocation[](1);
        allocations[0] = Allocation(port, channel, spendLimit, defaultAllowList);
        // Approve the contract address (grantee) for the specified allocations
        // The granter is always assumed to be the origin
        bool approved = ICS20_CONTRACT.approve(address(this), allocations);
        require(approved, "approval for IBC transfer failed");
    }

    /// @dev Builds a liquid staking memo that can parsed by the stride chain to trigger a liquid staking action
    /// @param _receiver the bech32 address of the receiver on the Stride chain
    function buildLiquidStakeMemo(string memory _receiver) public pure returns (string memory) {
        string memory memo = string(abi.encodePacked(
            '{',
                '"autopilot": {',
                    '"receiver": "', _receiver, '",',
                    '"stakeibc": {',
                        '"action": "LiquidStake"',
                    '}',
                '}',
            '}'
        ));

        return memo;
    }

    /// @dev Transfers the specified amount of "aevmos" to the specified receiver on the Stride chain
    /// with the correct memo to trigger a liquid staking action.
    /// NOTE - on testnet the base denom will be "atevmos"
    /// @param _amount The amount of "aevmos" to be swapped
    /// @param _receiver The bech32 address of the receiver on the Stride chain
    function liquidStakeEvmos(uint256 _amount, string memory _receiver) public {
        _approveTransfer(_amount, baseDenom);
        Height memory timeoutHeight = Height(100,100);
        string memory memo = buildLiquidStakeMemo(_receiver);

        ICS20_CONTRACT.transfer(
            port,
            channel,
            baseDenom,
            _amount,
            msg.sender,
            _receiver,
            timeoutHeight,
            0,
            memo
        );
    }
}
