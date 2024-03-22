// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.17;

import ".../../../precompiles/stateful/ICS20.sol";
import "../../precompiles/common/Types.sol";

contract XCSOutpost {

    // @dev struct to encapsulate memo parameters
    struct MemoParams {
        string outputDenom;
        string receiver;
        string forwardChannel;
    }

    /// @dev The constants for channel, port and base denom
    string private port = "transfer";
    string private XCS_CONTRACT = "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl"; // The XCS contract

    /// @dev Default allowed list is empty indicating no restrictions
    string[] private defaultAllowList = new string[](0);

    /// @dev Creates an approval allocation against the smart contract for IBC transfers.
    function _approveTransfer(uint256 _amount, string calldata channel, string calldata _baseDenom) private {
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


    /// @dev Preparation of memo field for cross chain swap by first sending the Coin to unwrap in it's native chain.
    function osmosisSwapForward(MemoParams calldata memoParams) public view returns (string memory) {
        string memory memo = string(abi.encodePacked(
            '{',
                '"forward": {',
                    '"receiver": "', XCS_CONTRACT, '",',
                    '"port": "transfer",',
                    '"channel": "', memoParams.forwardChannel, '",',
                    '"timeout": "2m",',
                    '"retries": 2,',
                    '"next": {',
                        '"wasm": {',
                        '"contract": "', XCS_CONTRACT, '",',
                            '"msg": {',
                                '"osmosis_swap": {',
                                    '"output_denom": "', memoParams.outputDenom, '",',
                                    '"receiver": "', memoParams.receiver, '",',
                                        '"slippage": {',
                                            '"twap": {',
                                            '"slippage_percentage": "20",',
                                            '"window_seconds": 30',
                                        '}',
                                    '},',
                                    '"on_failed_delivery": "do_nothing"',
                                '}',
                            '}',
                        '}',
                    '}',
                '}',
            '}'
        ));
        return memo;
    }

    /// @dev Swaps native tokens coming from Evmos for Evmos. This includes any ERC20s that are registered as IBC Coins.
    function osmosisSwapNative(MemoParams calldata memoParams) public view returns (string memory) {
        string memory memo = string(abi.encodePacked(
            '{',
                '"wasm": {',
                    '"contract": "', XCS_CONTRACT, '",',
                    '"msg": {',
                        '"osmosis_swap": {',
                            '"output_denom": "', memoParams.outputDenom, '",',
                            '"receiver": "', memoParams.receiver, '",',
                            '"slippage": {',
                                '"twap": {',
                                    '"slippage_percentage": "20",',
                                    '"window_seconds": 30',
                                '}',
                            '},',
                            '"on_failed_delivery": "do_nothing"',
                        '}',
                    '}',
                '}',
            '}'
        ));
        return memo;
    }

    // @dev The main Swap function which will swap a base denom for an output denom.
    function osmosisSwap(bool isNative, string calldata firstChannel, string memory _firstReceiver, uint256 _amount, string calldata _baseDenom, MemoParams calldata memoParams) public {
        _approveTransfer(_amount, firstChannel, _baseDenom);
        Height memory timeoutHeight = Height(100,100);

        string memory memo;
        if (isNative) {
            memo = osmosisSwapNative(memoParams);
        } else {
            memo = osmosisSwapForward(memoParams);
        }

        ICS20_CONTRACT.transfer(
            port,
            firstChannel,
            _baseDenom,
            _amount,
            msg.sender,
            _firstReceiver, // The cross chain swaps CosmWasm contract
            timeoutHeight,
            0,
            memo
        );
    }
}