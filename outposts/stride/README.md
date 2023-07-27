# Stride Liquid Stake Outpost

## Overview

The following is an example Stride Outpost smart contract that interacts with the
[Autopilot](https://github.com/Stride-Labs/stride/tree/main/x/autopilot) feature on the Stride chain.
Its purpose is to liquid stake assets like Evmos by directly calling a smart contract.


## How it works

The Autopilot feature is a middleware that triggers an action on the Stride chain
based on `memo` field of an IBC transfer transaction. We build this memo field so 
devs have a simple way to trigger actions on the Stride chain.

### Constants

This contract has the following constants:
- `channel` - the IBC channel on Evmos for Stride - `channel-25` **THIS IS FOR MAINNET**
- `port` - The IBC port for the transfer - `transfer`

### Functions

- `liquidStakeEvmos` - this is the main function of the Outpost, it requires an `amount` and `receiver`
  - `amount` - the amount of `aevmos` to liquid stake
  - `receiver` - the bech32 address of the receiver on the Stride chain, this can usually be found in Keplr
or the Stride dashboard
