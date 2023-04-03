// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.17;

/// @dev The ICS20I contract's address.
address constant IBC_TRANSFER_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000802;

/// @dev The ICS20 contract's instance.
IBCTransferI constant IBC_TRANSFER_CONTRACT = IBCTransferI(ICS20_PRECOMPILE_ADDRESS);

// Height is a monotonically increasing data type
// that can be compared against another Height for the purposes of updating and
// freezing clients
//
// Normally the RevisionHeight is incremented at each height while keeping
// RevisionNumber the same. However some consensus algorithms may choose to
// reset the height in certain conditions e.g. hard forks, state-machine
// breaking changes In these cases, the RevisionNumber is incremented so that
// height continues to be monotonically increasing even as the RevisionHeight
// gets reset
struct Height {
  // the revision that the client is currently on
  uint64 revisionNumber;
  // the height within the given revision
  uint64 revisionHeight;
}

// DenomTrace contains the base denomination for ICS20 fungible tokens and the
// source tracing information path.
struct DenomTrace {
  // path defines the chain of port/channel identifiers used for tracing the
	// source of the fungible token.
  string path;
  // base denomination of the relayed fungible token.
  string baseDenom;
}

/// @author Evmos Team
/// @title ICS20 Transfer Precompiled Contract
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
    function denomTraces(
    ) external returns (DenomTrace[] memory denomTraces);

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
    /// @param amount The amount of tokens to be spent.
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool approved);

    /// @dev Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through
    /// IBC transfers. This is zero by default.
    /// @param owner The address of the account owning tokens.
    /// @param spender The address of the account able to transfer the tokens.
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256 remaining);

    /// @dev Increase the allowance of a given spender by a specific amount of tokens for IBC transfer methods.
    /// @param spender The address which will spend the funds.
    /// @param amount The amount of tokens to be spent.
    function increaseAllowance(
        address spender,
        uint256 amount
    ) external returns (bool approved);

    /// @dev Decreases the allowance of a given spender by a specific amount of tokens for for IBC transfer methods.
    /// @param spender The address which will spend the funds.
    /// @param amount The amount of tokens to be spent.
    function decreaseAllowance(
        address spender,
        uint256 amount
    ) external returns (bool approved);


    /// @dev Emitted when a transfer is executed.
    /// @param sender The address of the sender.
    /// @param receiver The address of the receiver.
    /// @param denom The denomination of the tokens transferred.
    /// @param amount The amount of tokens transferred.
    event IBCTransfer(
        address indexed sender,
        address indexed receiver,
        string denom,
        uint256 amount
    );

    /// @dev Emitted when an approval is executed.
    /// @param owner The address of the owner.
    /// @param spender The address of the spender.
    /// @param value The amount of tokens approved.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
