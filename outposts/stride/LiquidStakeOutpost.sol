// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.17;

import ".../../../precompiles/stateful/ICS20.sol";
import "../../precompiles/common/Types.sol";

contract StrideOutpost {

    // The constants for channel and port
    string private channel = "channel-25";
    string private port = "transfer";
    string private baseDenom = "aevmos";
    string private stDenom = "ibc/C9364B2C453F0428D04FD40B6CF486BA138FA462FE43A116268A7B695AFCFE7F"; // The IBC denom of stAevmos

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
        ICS20Allocation[] memory allocations = new ICS20Allocation[](1);
        allocations[0] = ICS20Allocation(port, channel, spendLimit, defaultAllowList);
        // Approve the contract address (grantee) for the specified allocations
        // The granter is always assumed to be the origin
        bool approved = ICS20_CONTRACT.approve(address(this), allocations);
        require(approved, "approval for IBC transfer failed");
    }

    /// @dev Builds a liquid staking memo that can parsed by the stride chain to trigger a liquid staking action
    /// @param _strideReceiver the bech32 address of the receiver on the Stride chain
    /// @param _evmosReceiver the bech32 address of the receiver on Evmos
    function buildLiquidStakeMemo(string memory _strideReceiver, string memory _evmosReceiver) public pure returns (string memory) {
        string memory memo = string(abi.encodePacked(
            '{',
                '"autopilot": {',
                    '"receiver": "', _strideReceiver, '",',
                    '"stakeibc": {',
                        '"ibc_receiver":"', _evmosReceiver, '",',
                        '"action": "LiquidStake"',
                    '}',
                '}',
            '}'
        ));

        return memo;
    }

    /// @dev Builds the redeem memo that can be parsed by the stride chain to trigger the redeem action
    /// @param _strideReceiver the bech32 address of the receiver on the Stride chain
    /// @param _evmosReceiver the bech32 address of the receiver on Evmos
    function buildRedeemMemo(string memory _strideReceiver, string memory _evmosReceiver) public pure returns (string memory) {
        string memory memo = string(abi.encodePacked(
            '{',
                '"autopilot": {',
                    '"receiver": "', _strideReceiver, '",',
                    '"stakeibc": {',
                        '"transfer_channel": "channel-9"',
                        '"ibc_receiver":"', _evmosReceiver, '",',
                        '"action": "RedeemStake"',
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
    /// @param _strideReceiver The bech32 address of the receiver on the Stride chain
    /// @param _evmosReceiver The bech32 address of the receiver on the Stride chain
    function liquidStakeEvmos(uint256 _amount, string memory _strideReceiver, string memory _evmosReceiver) public {
        _approveTransfer(_amount, baseDenom);
        Height memory timeoutHeight = Height(100,100);
        string memory memo = buildLiquidStakeMemo(_strideReceiver, _evmosReceiver);

        ICS20_CONTRACT.transfer(
            port,
            channel,
            baseDenom,
            _amount,
            msg.sender,
            _strideReceiver,
            timeoutHeight,
            0,
            memo
        );
    }

    /// @dev Transfers the specified amount of "staevmos" to the specified receiver on the Stride chain
    /// with the correct memo to trigger a redeem stake action.
    /// @param _amount The amount of "stEvmos" to be redeemed
    /// @param _strideReceiver The bech32 address of the receiver on the Stride chain
    /// @param _evmosReceiver The bech32 address of the receiver on the Stride chain
    function redeemStEvmos(uint256 _amount, string memory _strideReceiver, string memory _evmosReceiver) public {
        _approveTransfer(_amount, stDenom);
        Height memory timeoutHeight = Height(100,100);
        string memory memo = buildRedeemMemo(_strideReceiver, _evmosReceiver);

        ICS20_CONTRACT.transfer(
            port,
            channel,
            stDenom,
            _amount,
            msg.sender,
            _strideReceiver,
            timeoutHeight,
            0,
            memo
        );
    }
}