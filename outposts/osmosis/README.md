# Osmosis Cross Chain Swap (XCS) Outpost

## Overview

The following is an example Osmosis Outpost smart contract that interacts with the
[Osmosis Cross Chain Swap contract](https://github.com/osmosis-labs/osmosis/tree/be63fb58580b87808f6d7ed9523a43e976899258/cosmwasm/contracts/crosschain-swaps).
This contract can be deployed as a standalone contract and called
from other contracts, or you can include this logic
into your own contract. In this case you can swap any non-native Coin to Evmos
and receive them back on the Evmos chain.

Future versions of this contract will include swapping Evmos for any non-native Coin like ATOM, INJ, TIA etc.

## How it works

### Osmosis

The Osmosis Outpost contract is a CosmWasm contract deployed on the Osmosis chain.
It consists of two separate contracts:

- [crosschain_swaps](https://celatone.osmosis.zone/testnet/contracts/osmo1ye7nsslrgwc6ngmav67h26zckg8wjeay4agnlzke66f8apq3ls8sqednc4) -
 this contract checks for a correct `memo` field and routes to the `swaprouter` contract.
- [swaprouter](https://celatone.osmosis.zone/testnet/contracts/osmo1cr8pd93vrw236jqr696p23k0g37dzkegjjf9884023ts48yazxhsj38hlv) -
 the swap router performs the actual swap. It requires a configuration for the pools a user wants to use to swap. The
swap router contract can construct swap paths using the `set_route` transaction. You can compose routes between different
pools in order to get the desired output denom. Below is an example of a route that starts with axlUSDC, swaps it for
Osmosis and then swaps that Osmosis for Evmos using different pools.
```json
{
   "set_route": {
    "input_denom": "ibc/D189335C6E4A68B513C10AB227BF1C1D38C746766278BA3EEB4FB14124F1D858",
    "output_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A",
    "pool_route": [
      {
        "pool_id": "1133",
        "token_out_denom": "uosmo"
      },
      {
        "pool_id": "722",
        "token_out_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A"
      }
    ]
  }
}
```

### Evmos

On Evmos all you need to do is deploy and call the swapping function on the `XSCOutpost` contract,
the memo field is constructed automatically using the helper function.
You will be sending different denoms and in return receive Evmos or Osmosis tokens. At the bottom of this 
document you will find constructed `memos` and the parameters you need to provide to the `swap` function.



## Tested Swap Pairs and `memo` fields

### ATOM -> EVMOS

- calls - `osmosisSwap` -> `osmosisSwapForward`
- params
  - `isNative` - `false`
  - `firstChannel` - `channel-3`
  - `_firstReceiver` - **YOUR COSMOS HUB ADDRESS**
  - `_amount` - **AMOUNT**
  - `_baseDenom` - `ibc/A4DB47A9D3CF9A068D454513891B526702455D3EF08FB9EB558C561F9DC2B701`
  - `memoParams` - `["ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A","YOUR EVMOS BECH32 ADDRESS","channel-141"]`
- final `memo`
```json
{
 "forward": {
  "receiver": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
  "port": "transfer",
  "channel": "channel-141",
  "timeout": "2m",
  "retries": 2,
  "next": {
   "wasm": {
    "contract": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
    "msg": {
     "osmosis_swap": {
      "output_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A",
      "receiver": "YOUR EVMOS RECEIVER",
      "slippage": {
       "twap": {
        "slippage_percentage": "20",
        "window_seconds": 30
       }
      },
      "on_failed_delivery": "do_nothing"
     }
    }
   }
  }
 }
}
```

### USDC -> EVMOS

- calls - `osmosisSwap` -> `osmosisSwapForward`
- params
 - `isNative` - `false`
 - `firstChannel` - `channel-64`
 - `_firstReceiver` - **YOUR NOBLE ADDRESS**
 - `_amount` - **AMOUNT**
 - `_baseDenom` - `ibc/35357FE55D81D88054E135529BB2AEB1BB20D207292775A19BD82D83F27BE9B4` 
 - `memoParams` - `["ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A","YOUR EVMOS BECH32 ADDRESS","channel-1"]`
- final `memo`
```json
{
 "forward": {
  "receiver": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
  "port": "transfer",
  "channel": "channel-1",
  "timeout": "2m",
  "retries": 2,
  "next": {
   "wasm": {
    "contract": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
    "msg": {
     "osmosis_swap": {
      "output_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A",
      "receiver": "YOUR EVMOS RECEIVER", 
      "slippage": {
       "twap": {
        "slippage_percentage": "20",
        "window_seconds": 30
       }
      },
      "on_failed_delivery": "do_nothing"
     }
    }
   }
  }
 }
}
```

### INJ -> EVMOS

- calls - `osmosisSwap` -> `osmosisSwapForward`
- params
 - `isNative` - `false`
 - `firstChannel` - `channel-10`
 - `_firstReceiver` - **YOUR INJECTIVE ADDRESS**
 - `_amount` - **AMOUNT**
 - `_baseDenom` - `ibc/ADF401C952ADD9EE232D52C8303B8BE17FE7953C8D420F20769AF77240BD0C58` 
 - `memoParams` - `["ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A","YOUR EVMOS BECH32 ADDRESS","channel-8"]`
- final `memo`
```json
{
 "forward": {
  "receiver": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
  "port": "transfer",
  "channel": "channel-8",
  "timeout": "2m",
  "retries": 2,
  "next": {
   "wasm": {
    "contract": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
    "msg": {
     "osmosis_swap": {
      "output_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A", 
      "receiver": "YOUR EVMOS RECEIVER",
      "slippage": {
       "twap": {
        "slippage_percentage": "20",
        "window_seconds": 30
       }
      },
      "on_failed_delivery": "do_nothing"
     }
    }
   }
  }
 }
}
```

### STARS -> EVMOS

- calls - `osmosisSwap` -> `osmosisSwapForward`
- params
 - `isNative` - `false`
 - `firstChannel` - `channel-13`
 - `_firstReceiver` - **YOUR STARGAZE ADDRESS**
 - `_amount` - **AMOUNT**
 - `_baseDenom` - `ibc/7564B7F838579DD4517A225978C623504F852A6D0FF7984AFB28F10D36022BE8` 
 - `memoParams` - `["ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A","YOUR EVMOS BECH32 ADDRESS","channel-0"]`
- final `memo`
```json
{
 "forward": {
  "receiver": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
  "port": "transfer",
  "channel": "channel-0",
  "timeout": "2m",
  "retries": 2,
  "next": {
   "wasm": {
    "contract": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
    "msg": {
     "osmosis_swap": {
      "output_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A", 
      "receiver": "YOUR EVMOS RECEIVER",
      "slippage": {
       "twap": {
        "slippage_percentage": "20",
        "window_seconds": 30
       }
      },
      "on_failed_delivery": "do_nothing"
     }
    }
   }
  }
 }
} 
```

### NEOK -> EVMOS

- calls - `osmosisSwap` -> `osmosisSwapNative`
- params
 - `isNative` - `true`
 - `firstChannel` - `channel-0`
 - `_firstReceiver` - ``
 - `_amount` - **AMOUNT**
 - `_baseDenom` - `erc20/0x655ecB57432CC1370f65e5dc2309588b71b473A9` 
 - `memoParams` - `["ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A","YOUR EVMOS BECH32 ADDRESS", ""]`
- final `memo`
```json
{
  "wasm": {
    "contract": "osmo14f7h97tyavuqqnu68ftm6u7xlkvr2ex58f8pjjj27f6saj5en7jsj9u3nl",
    "msg": {
      "osmosis_swap": {
        "output_denom": "ibc/6AE98883D4D5D5FF9E50D7130F1305DA2FFA0C652D1DD9C123657C6B4EB2DF8A",
        "receiver": "YOUR EVMOS RECEIVER",
        "slippage": {
          "twap": {
            "slippage_percentage": "20",
            "window_seconds": 30
          }
        },
        "on_failed_delivery": "do_nothing"
      }
    }
  }
}
```