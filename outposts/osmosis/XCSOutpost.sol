// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.17;

import ".../../../precompiles/stateful/ICS20.sol";

contract XCSOutpost {

    /// @dev The constants for channel, port and base denom
    string private channel = "channel-157";
    string private port = "transfer";
    string private XCS_CONTRACT = "osmo1ye7nsslrgwc6ngmav67h26zckg8wjeay4agnlzke66f8apq3ls8sqednc4";

    /// @dev Default allowed list is empty indicating no restrictions
    string[] private defaultAllowList = new string[](0);

    /// @dev Creates an approval allocation against the smart contract for IBC transfers.
    function _approveTransfer(uint256 _amount, string calldata _baseDenom) private {
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


    /// @dev Preparation of memo field for cross chain swap for case 4 - Native (atevmos) to Osmosis Native (uosmo)
    /// @param _output_denom The target denomination to be swapped for, e.g. "uosmo"
    /// @param _receiver The address bech32 string receiving the swapped funds
    function nativeToOsmoNativeMemo(string memory _output_denom, string memory _receiver) public pure returns (string memory) {
        string memory part1 = "{\"wasm\": {\"contract\": \"osmo1ye7nsslrgwc6ngmav67h26zckg8wjeay4agnlzke66f8apq3ls8sqednc4\", \"msg\": {\"osmosis_swap\": {\"output_denom\":\"";
        string memory part2 = "\", \"slippage\": {\"twap\": {\"slippage_percentage\": \"20\", \"window_seconds\": 20}}, \"receiver\":\"";
        string memory part3 = "\", \"on_failed_delivery\": \"do_nothing\"}}}}";

        return string(abi.encodePacked(part1, _output_denom, part2, _receiver, part3));
    }

    // @dev The main Swap function which will swap a base denom for an output denom using the native to osmosis native case
    // @param _amount The amount of the base denomination to be swapped
    // @param _baseDenom The base denomination used for the swap, e.g. "atevmos" for Evmos testnet
    // @param _outputDenom The target denomination to be swapped for, e.g. "uosmo"
    // @param _receiver The address bech32 string receiving the swapped funds
    function osmosisSwap(uint256 _amount, string calldata _baseDenom, string calldata _outputDenom, string calldata _receiver) public {
        _approveTransfer(_amount, _baseDenom);
        Height memory timeoutHeight = Height(100,100);
        string memory memo = nativeToOsmoNativeMemo(_outputDenom, _receiver);

        ICS20_CONTRACT.transfer(
            port,
            channel,
            _baseDenom,
            _amount,
            msg.sender,
            XCS_CONTRACT, // The cross chain swaps CosmWasm contract
            timeoutHeight,
            0,
            memo
        );
    }
}
