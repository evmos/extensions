// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.17;

/// @author Evmos Team
/// @title Authorization Interface
/// @dev The interface through which solidity contracts will interact with smart contract approvals.
interface GenericAuthorizationI {
    /// @dev Approves a list of Cosmos or IBC transactions with a specific amount of tokens.
    /// @param spender The address which will spend the funds.
    /// @param methods The message type URLs of the methods to approve.
    /// @return approved Boolean value to indicate if the approval was successful.
    function approve(
        address spender,
        string[] calldata methods
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
        string[] methods
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
