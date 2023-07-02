# Simple Staker

This is an example of how to create a smart contract that directly calls the `Staking` and `Distribution` precompiled contracts - [Simple Staker](./contracts/SimpleStaker.sol)

This smart contract allows the user to:

- Stake tokens
- Withdraw delegation rewards
- Query current delegations
- Query current delegations rewards

The implementation is straightforward and is a good starting point for anyone who wants to create a smart contract that interacts with the Cosmos SDK.

There are a couple of things to keep in mind when using the precompiled contracts:

## Approvals

Before executing any transaction on the precompiled contracts,
the user interacting with the smart contract must first approve these.
In case of staking transactions, should specify the amount allowed.
The smart contract developer can choose to either separate
the approval and execution of the precompiled contracts transactions
or to combine them into a single transaction.

We have provided convenient constants - `MSG_DELEGATE`, `MSG_UNDELEGATE`,
`MSG_REDELEGATE`, `MSG_CANCEL_UNDELEGATION`, `MSG_SET_WITHDRAWER_ADDRESS`,
`MSG_WITHDRAW_DELEGATOR_REWARD`, `MSG_WITHDRAW_VALIDATOR_COMMISSION` - for easier use.

This is done by calling the `approve` function and will create an authorization grant for the given Cosmos SDK message
for the given spender address (this usually should be `address(this)` to approve the calling contract.

Use the corresponding method when approving methods for each precompiled
(e.g., use `STAKING_CONTRACT.approve(...)` for staking methods)
The distribution contract does not require approvals.

The [Simple Staker](./contracts/SimpleStaker.sol) has the function `approveRequiredMethods()`
to perform the necessary approvals.
It approves the required methods for staking tokens (`MSG_DELEGATE`)

## Allowances

The `Staking` precompile will check if the message sender has enough allowance for the given message type and will
return an error if the transaction exceeds the allowance.

Decreasing the allowance after a successful transaction is not required since we handle it internally.

## Return Structs

The precompiled contracts provide a set of structs that map to Cosmos SDK message returns types.

These structs can be used as return types for smart contract functions or can be used to add further
logic to your smart contracts. Once a transaction is executed, the return values can be used to verify the transaction
was successful or be as inputs for additional logic.

## Failed Transactions

The precompiled contracts provide verbose error messages for failed transactions. If a transaction fails, the state
will not be persisted and the transaction will be reverted.
