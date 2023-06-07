// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.17;

import "../common/Types.sol";

/// @dev The ICS20I contract's address.
address constant IBC_TRANSFER_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000802;

/// @dev The ICS20 contract's instance.
IBCTransferI constant IBC_TRANSFER_CONTRACT = IBCTransferI(
    IBC_TRANSFER_PRECOMPILE_ADDRESS
);

/// @dev DenomTrace contains the base denomination for ICS20 fungible tokens and the
/// source tracing information path.
struct DenomTrace {
    // path defines the chain of port/channel identifiers used for tracing the
    // source of the fungible token.
    string path;
    // base denomination of the relayed fungible token.
    string baseDenom;
}

/// @dev Allocation defines the spend limit for a particular IBC port and channel
struct Allocation {
    string sourcePort;
    string sourceChannel;
    string denom;
    uint256 amount;
    string[] allowList;
}

/// @author Evmos Team
/// @title IBC Transfer Precompiled Contract
/// @dev The interface through which solidity contracts will interact with IBC Transfer (ICS20)
/// FIXME: update address
/// @custom:address 0x0000000000000000000000000000000000000802
interface IBCTransferI {
    /// @dev Transfer defines a method for performing an IBC transfer.
    /// @param sourcePort the address of the validator
    /// @param sourceChannel the address of the validator
    /// @param denom the denomination of the Coin to be transferred to the receiver
    /// @param amount the amount of the Coin to be transferred to the receiver
    /// @param sender the hex address of the sender
    /// @param receiver the bech32 address of the receiver
    /// @param timeoutHeight the bech32 address of the receiver
    /// @param timeoutTimestamp the bech32 address of the receiver
    /// @param memo the bech32 address of the receiver
    function transfer(
        string memory sourcePort,
        string memory sourceChannel,
        string memory denom,
        uint256 amount,
        address sender,
        string memory receiver,
        Height memory timeoutHeight,
        uint64 timeoutTimestamp,
        string memory memo
    ) external returns (uint64 nextSequence);

    /// @dev DenomTraces defines a method for returning all denom traces.
    function denomTraces() external returns (DenomTrace[] memory denomTraces);

    /// @dev DenomTrace defines a method for returning a denom trace.
    function denomTrace(
        string memory hash
    ) external returns (DenomTrace memory denomTrace);

    /// @dev DenomHash defines a method for returning a hash of the denomination trace info.
    function denomHash(
        string memory trace
    ) external returns (string memory hash);

    /// @dev Approves IBC transfer with a specific amount of tokens.
    /// @param spender spender The address which will spend the funds.
    /// @param allocations the allocations for the authorization.
    function approve(
        address spender,
        Allocation[] calldata allocations
    ) external returns (bool approved);

    /// @dev Revokes IBC transfer authorization for a specific spender
    /// @param spender spender The address which will spend the funds.
    function revoke(address spender) external returns (bool revoked);

    /// @dev Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through
    /// IBC transfers. This is zero by default.
    /// @param owner The address of the account owning tokens.
    /// @param spender The address of the account able to transfer the tokens.
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256 remaining);

    /// @dev Increase the allowance of a given spender by a specific amount of tokens and IBC connection for IBC transfer methods.
    /// @param spender The address which will spend the funds.
    /// @param sourcePort The source port of the IBC transaction.
    /// @param sourceChannel The source channel of the IBC transaction.
    /// @param denom The denomination of the tokens transferred.
    /// @param amount The amount of tokens to be spent.
    function increaseAllowance(
        address spender,
        string calldata sourcePort,
        string calldata sourceChannel,
        string calldata denom,
        uint256 amount
    ) external returns (bool approved);

    /// @dev Decreases the allowance of a given spender by a specific amount of tokens for for IBC transfer methods.
    /// @param spender The address which will spend the funds.
    /// @param sourcePort The source port of the IBC transaction.
    /// @param sourceChannel The source channel of the IBC transaction.
    /// @param denom The denomination of the tokens transferred.
    /// @param amount The amount of tokens to be spent.
    function decreaseAllowance(
        address spender,
        string calldata sourcePort,
        string calldata sourceChannel,
        string calldata denom,
        uint256 amount
    ) external returns (bool approved);

    /// @dev Emitted when an ICS-20 transfer is executed.
    /// @param sender The address of the sender.
    /// @param receiver The address of the receiver.
    /// @param denom The denomination of the tokens transferred.
    /// @param amount The amount of tokens transferred.
    /// @param memo The IBC transaction memo.
    event IBCTransfer(
        address indexed sender,
        string indexed receiver,
        string denom,
        uint256 amount,
        string memo
    );

    /// @dev Emitted when an ICS-20 transfer authorization is granted.
    /// @param grantee The address of the grantee.
    /// @param granter The address of the granter.
    /// @param sourcePort The source port of the IBC transaction.
    /// @param sourceChannel The source channel of the IBC transaction.
    /// @param denom The denomination of the tokens transferred.
    /// @param amount The amount of tokens transferred.
    event IBCTransferAuthorization(
        address indexed grantee,
        address indexed granter,
        string sourcePort,
        string sourceChannel,
        string denom,
        uint256 amount
    );

    /// @dev This event is emitted when an owner revokes a spender's allowance.
    /// @param owner The owner of the tokens.
    /// @param spender The address which will spend the funds.
    event RevokeIBCTransferAuthorization(
        address indexed owner,
        address indexed spender
    );

    /// @dev This event is emitted when the allowance of a spender is changed by a call to the decrease or increase
    /// allowance method. The values field specifies the new allowances and the methods field holds the
    /// information for which methods the approval was set.
    /// @param owner The owner of the tokens.
    /// @param spender The address which will spend the funds.
    /// @param methods The message type URLs of the methods for which the approval is set.
    /// @param values The amounts of tokens approved to be spent.
    event AllowanceChange(
        address indexed owner,
        address indexed spender,
        string[] methods,
        uint256[] values
    );
}
