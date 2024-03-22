# Stride Liquid Stake Outpost

## Overview

The following is an example Stride Outpost smart contract that interacts with the
[Autopilot](https://github.com/Stride-Labs/stride/tree/main/x/autopilot) feature on the Stride chain.
Its purpose is to liquid stake assets like Evmos by directly calling a smart contract.

## Mainnet

The following contract is configured for mainnet and would **NOT** work 
on testnet without changing the configurations located at the top of the contract.

```solidity
    // The constants for channel and port for testnet
    string private channel = "channel-25";
    string private port = "transfer";
    string private baseDenom = "aevmos";
    // The IBC denom of statevmos
    string private stDenom = "ibc/C9364B2C453F0428D04FD40B6CF486BA138FA462FE43A116268A7B695AFCFE7F"; 
```

## How it works

The Autopilot feature is a middleware that triggers an action on the Stride chain
based on `memo` field of an IBC transfer transaction. We build this memo field so 
devs have a simple way to trigger actions on the Stride chain.

### Constants

This contract has the following constants:
- `channel` - the IBC channel on Evmos for Stride - `channel-25`
- `port` - The IBC port for the transfer - `transfer`
- `baseDenom` - The base denom we are sending to the Stride chain - `aevmos`
- `stDenom` - The IBC denom representation of Evmos for `stAevmos`

### Functions

- `liquidStakeEvmos` - this is the main function of the Outpost, it requires an `amount` and `receiver`
  - `_amount` - the amount of `aevmos` to liquid stake
  - `_strideReceiver` - the bech32 address of the receiver on the Stride chain, this can usually be found in Keplr
or the Stride dashboard
  - `_evmosReceiver` - the bech32 address of the receiver on the Evmos chain. This can be any address.

- `redeemStEvmos` - this function redeems `stAevmos` for `aevmos`.
  - `_amount` - the amount of `stAevmos` to redeem
  - `_strideReceiver` - the bech32 address of the receiver on the Stride chain, this can usually be found in Keplr
    or the Stride dashboard
  - `_evmosReceiver` - the bech32 address of the receiver on the Evmos chain. This can be any address.
