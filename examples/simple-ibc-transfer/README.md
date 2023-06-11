## Simple IBC transfer

This is a simple IBC transfer showcase using the ICS20 precompile interface. It sends EVMOS tokens
from the Evmos blockchain to the Osmosis blockchain using the IBC transfer module.

## Approvals

Before executing any IBC transfer related transactions, the user interacting with the smart contract must first approve
any number of coins using the `Allocation` struct. The smart contract developer can choose to either separate
the approval and execution of the IBC transfer or to combine them into a single transaction.
