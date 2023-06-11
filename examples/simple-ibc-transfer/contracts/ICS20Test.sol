// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.18;

import "./ICS20.sol";

contract ICS20Test {

    // The constants for channel, port and base denom
    string private channel = "channel-0";
    string private port = "transfer";
    string private baseDenom = "aevmos";

    // Default allowed list is empty indicating no restrictions
    string[] private defaultAllowList = new string[](0);

    // Sends coins to Osmosis chain via IBC transfer on the specified channel and port.
    function sendEvmosToOsmosis(uint256 _amount) public {
        // Approve only the amount to be send
        _approveTransfer(_amount);
        // Send IBC transfer using the interface function `transfer`
        ICS20_CONTRACT.transfer(
            port,
            channel,
            baseDenom,
            _amount,
            msg.sender,  // The sender address
            "osmo1uqy7a69nv7qzjp6upcudxy00ykn6k0h59763ww", // The bech32 address of the receiver wallet on the Osmosis chain
            Height(1000, 1000),
            0,
            "" // The memo field used for advanced functionality (blank here)
        );
    }

    // Creates an approval allocation against the smart contract for IBC transfers.
    function _approveTransfer(uint256 _amount) public {
        // Create the spend limit of coins, in this case only aevmos
        Coin[] memory spendLimit = new Coin[](1);
        spendLimit[0] = Coin(baseDenom, _amount);
        // Create allocation for coins on the specified channel and port
        Allocation[] memory allocations = new Allocation[](1);
        allocations[0] = Allocation(port, channel, spendLimit, defaultAllowList);
        // Approve the contract address (grantee) for the specified allocations
        // The granter is always assumed to be the origin
        bool approved = ICS20_CONTRACT.approve(address(this), allocations);
        require(approved, "approval for IBC transfer failed");
    }

}
