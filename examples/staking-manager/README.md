# Staking Manager

This is an example of how to create a smart contract that directly calls the `Staking` precompiled contract - [Staking Manager](./contracts/StakingManager.sol)

The implementation is straight forward and is a good starting point for anyone who wants to create a smart contract that interacts with the Cosmos SDK.

There are a couple of things to keep in mind when using the `Staking` precompile:

## Approvals
Before executing any staking related transactions, the user interacting with the smart contract must first approve 
any number of staking transactions for with a specified amount.

We have provided convenient constants - `MSG_DELEGATE`, `MSG_UNDELEGATE`, `MSG_REDELEGATE`, `MSG_CANCEL_UNDELEGATION` for easier use.

This is done by calling the `approve` function and will create an authorization grant for the given Cosmos SDK message. 


## Allowances
The `Staking` precompile will check if the message sender has enough allowance for the given message type and will
return an error if the transaction exceeds the allowance.

Decreasing the allowance after a successful transaction is not required since we handle it internally.


## Return Structs
The `Staking` precompile provides a set of structs that map to Cosmos SDK message returns types. 

These structs can be used as return types for smart contract functions and can be used to add further logic to your smart contracts.

