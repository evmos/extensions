# Stride Liquid Stake Outpost

## Overview

The following is an example Stride Outpost smart contract that interacts with the
[Autopilot](https://github.com/Stride-Labs/stride/tree/main/x/autopilot) feature on the Stride chain.
Its purpose is to liquid stake assets like Evmos by directly calling a smart contract.

## Testnet

The following contract is configured for testnet and would **NOT** work 
on mainnet without changing the configurations located at the top of the contract.

```solidity
    // The constants for channel and port
    // TODO: These need to change to reflect mainnet
    string private channel = "channel-216";
    string private port = "transfer";
    string private baseDenom = "atevmos";
    // The IBC denom of statevmos
    string private stDenom = "ibc/85F765A054C500BC1DD455231B08FC666948D1610228AE60300A5D809A3A826F"; 
```

## How it works

The Autopilot feature is a middleware that triggers an action on the Stride chain
based on `memo` field of an IBC transfer transaction. We build this memo field so 
devs have a simple way to trigger actions on the Stride chain.

### Constants

This contract has the following constants:
- `channel` - the IBC channel on Evmos for Stride - `channel-25` **THIS IS FOR MAINNET**
- `port` - The IBC port for the transfer - `transfer`
- `baseDenom` - The base denom we are sending to the Stride chain - `aevmos` or for testnet `atevmos`
- `stDenom` - The IBC denom representation of Evmos for `stEvmos`

### Functions

- `liquidStakeEvmos` - this is the main function of the Outpost, it requires an `amount` and `receiver`
  - `_amount` - the amount of `aevmos` to liquid stake
  - `_strideReceiver` - the bech32 address of the receiver on the Stride chain, this can usually be found in Keplr
or the Stride dashboard
  - `_evmosReceiver` - the bech32 address of the receiver on the Evmos chain. This can be any address.

- `redeemStEvmos` - this function redeems `staevmos` for `aevmos`.
  - `_amount` - the amount of `staevmos` to liquid stake
  - `_strideReceiver` - the bech32 address of the receiver on the Stride chain, this can usually be found in Keplr
    or the Stride dashboard
  - `_evmosReceiver` - the bech32 address of the receiver on the Evmos chain. This can be any address.
