# Osmosis Cross Chain Swap (XCS) Outpost

## Overview
The following is an example Osmosis Outpost contract that interacts with the 
[Osmosis Cross Chain Swap contract](https://github.com/osmosis-labs/osmosis/tree/be63fb58580b87808f6d7ed9523a43e976899258/cosmwasm/contracts/crosschain-swaps),
and specifically version 1 of the contract for the [**Native to Osmosis Native swap**](https://github.com/osmosis-labs/osmosis/tree/main/cosmwasm/contracts/crosschain-swaps#non-native-to-non-native). 
In this case you can swap Evmos for Osmosis tokens and receive them back on the Evmos chain. 
This functionality is available only for the latest Evmos and Osmosis testnets.


## How it works
### Osmosis
The Osmosis Outpost contract is a CosmWasm contract deployed on the Osmosis chain. It consists of two separate contracts:
- [crosschain_swaps](https://celatone.osmosis.zone/testnet/contracts/osmo1ye7nsslrgwc6ngmav67h26zckg8wjeay4agnlzke66f8apq3ls8sqednc4) - 
 this contract checks for a correct `memo` field and routes to the `swaprouter` contract.
- [swaprouter](https://celatone.osmosis.zone/testnet/contracts/osmo1cr8pd93vrw236jqr696p23k0g37dzkegjjf9884023ts48yazxhsj38hlv) -
 the swap router performs the actual swap. It requires a configuration for the pools a user wants to use to swap.

## Evmos
On Evmos all you need to do is call the swapping function on the `XSCOutpost` contract, the memo field is constructed,
automatically using the helper function. You will be sending `atevmos` and in return receive `osmo` tokens which will have 
an ibc voucher denom of: `ibc/95AEB3C077D1E35BA2AA79E338EB5B703C835C804127F7CC4942C8F23F710B26`


## Testnet
This contract is configured for testnet and would **NOT** work on mainnet without changing the configurations.
The channel id, contract address and pool ids are all testnet specific. 
For mainnet this document and the contract will be updated with the correct values.

**NOTE** - Moreover the [evmos/osmo pool 48](https://testnet.osmosis.zone/pool/48) was setup in a way that 1 aevmos = 1 osmo.
On mainnet this will not be the case as it will take into consideration the different token precisions and the swap will be adjusted.
On mainnet: evmos token precision = 18, osmo token precision = 6.


## Mainnet
TODO
