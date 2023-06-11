// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.17 .0;

/// @author Evmos Team
/// @title Distribution Authorization Interface
/// @dev The interface through which solidity contracts will interact with smart contract approvals.
interface DistributionAuthorizationI {
    /// @dev Approves a list of Cosmos transactions with a specific allowed list of addresses.
    /// @param spender The address which will spend the funds.
    /// @param methods The message type URLs of the methods to approve.
    /// @param allowedList The list of allowed addresses.
    /// @return approved Boolean value to indicate if the approval was successful.
    function approve(
        address spender,
        string[] calldata methods,
        string[] calldata allowedList
    ) external returns (bool approved);

    /// @dev Revokes a list of Cosmos transactions.
    /// @param spender The address which will spend the funds.
    /// @param methods The message type URLs of the methods to revoke.
    /// @return revoked Boolean value to indicate if the revocation was successful.
    function revoke(
        address spender,
        string[] calldata methods
    ) external returns (bool revoked);

    /// @dev This event is emitted when the allowance of a spender is set by a call to the approve method.
    /// The value field specifies the new allowance and the methods field holds the information for which methods
    /// the approval was set.
    /// @param owner The owner of the tokens.
    /// @param spender The address which will spend the funds.
    /// @param methods The message type URLs of the methods for which the approval is set.
    event Approval(
        address indexed owner,
        address indexed spender,
        string[] methods,
        string[] allowedList
    );

    /// @dev This event is emitted when an owner revokes a spender's allowance.
    /// @param owner The owner of the tokens.
    /// @param spender The address which will spend the funds.
    /// @param methods The message type URLs of the methods for which the approval is set.
    event Revocation(
        address indexed owner,
        address indexed spender,
        string[] methods
    );
}
