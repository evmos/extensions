# EVM Extensions

*🚧 NOTE: This project is still a work in progress 🚧*

This repository contains all currently supported EVM Extensions
(stateful precompiled contracts) for the [Evmos](https://evmos.org/) blockchain
as well as a set of example contracts that can be used to test the capabilities of EVM Extensions.
This repository is **WIP** and will be updated regularly
as new contracts are added and new use cases are explored.

## What are EVM Extensions?

Evmos’ unique implementation of stateful precompiles are called EVM Extensions.
For the first time, this will allow not only blockchains
but also individual applications to leverage and customize
the functionality of IBC and other Cosmos SDK modules.
Thus, these extensions push the EVM’s capabilities
past its original specification without breaking equivalence with Ethereum’s execution layer.
With the use of EVM Extensions, developers will be able to create their own business logic
for connecting with other smart contracts and app chains in the Cosmos ecosystem.
Applications will be freed from the confines of a single blockchain
and able to make smart contract calls to IBC modules to communicate with other chains,
send and receive assets between chains trustlessly, stake EVMOS tokens,
and even manage accounts on other blockchains to access any functionality built elsewhere.

## Using this repository

### Prerequisites

- Familiarity with Solidity interfaces - [Interfaces by example](https://solidity-by-example.org/interface/)
- Familiarity with Cosmos SDK modules - `x/staking` `x/distribution`, `ics20`, and `x/authz`.
- Familiarity with token approval mechanism similar to how `ERC20` tokens are approved for transfer.

### Structure

- `examples/`  contracts that utilize precompiled contracts to interact with the Cosmos SDK.
- `precompiles/` contains Solidity interfaces for all currently supported precompiled contracts
  - `abi/` contains the generated ABI for each precompile
  - `stateful/` - contains the Solidity interfaces for all stateful precompiles (ones that change state on the blockchain)
  - `stateless/` - contains the Solidity interfaces for all stateless precompiles (ones that do not change state on the blockchain)
  - `common/` - contains the Solidity interfaces for all common types used by precompiles
  