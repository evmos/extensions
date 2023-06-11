# No Loss Lottery

This is an example of how to create a smart contract for a no-loss-lottery that utilizes
the `Staking` and `Distribution` precompiled contracts - [NoLossLottery](./contracts/NoLossLottery.sol)

A no-loss-lottery is a lottery where users deposit funds into a pool and delegate them to a validator. Once a day
when the staking rewards are distributed, a random winner is picked from the pool of users based on their
deposit amount (the higher deposit the better odds of winning the pool). The winner receives the total pot of rewards 
for that day. The users that did not win the lottery can withdraw their funds at any time without losing any 
of their initial deposit.

The contract showcases how you can use the contract itself as a manager of funds to ensure
that users cannot undelegate their funds at any time skewing the lottery results.

**THIS IS NOT A COPY / PASTE CONTRACT** as it has certain limitations and is generally not production ready.

## Implementation

### Deposits


The contract uses its own balance as a pool of funds that users can deposit into. The contract
then uses the `Staking` precompile to delegate the funds to a validator. This ensures that the funds
are locked and cannot be undelegated from outside the contract. The contract keeps track of which user
delegated how much.

### Enter Lottery


The contract allows users to enter the lottery by using the funds they have deposited into the contract
to delegate to a validator.

### Draw Lottery


The contract uses the `Distribution` precompile to calculate the rewards of the total pool of funds. Each user
is assigned a number of tickets based on the amount of tokens they have delegated. Users are shuffled before each draw
and the winner is selected based on the number of tickets they have and a random number.

### Withdraw Winnings


The contract keeps track of which user won each round and allows them to withdraw the winnings in a separate
transaction called `withdrawWinnings`.

### Exit Lottery


The contract allows users to exit the lottery by undelegating their funds from the validator. **NOTE** only
the total amount delegated can be undelegated for simplicity. Once the 14 day unbonding period is over the
funds return to the contract and users can withdraw their funds using the `withdraw` function.

## Limitations

### No SafeMath 


The contract does not use OpenZeppelin's `SafeMath` library. This is fine for a showcase but be aware when deploying
to testnet or mainnet you would need to use `SafeMath` to prevent overflows.

### No Oracle randomness


The contract does not use an oracle for its random number generator or `shuffleParticipants` function.
This is fine for a showcase but be aware when deploying to testnet or mainnet you would need a verifiable
source of randomness.


### No Owner for the Contract


The contract does not implement OpenZeppelin's `Ownable` contract. This can cause issues as anybody can
execute the `pickWinner` function. Ideally some functions should be restricted to the owner of the contract
like the `pickWinner` function which should be triggered off-chain a couple of seconds after the
delegation rewards have been distributed

### No Multiple Validators


The contract does not handle users delegating to multiple validators. This is for simplicity’s sake as this would require
keeping track of which users have delegated to which validators and would require a more complex implementation.

### No Partial Exit Lottery


The contract does not allow multiple undelegations with smaller amounts from the validator.
This is for simplicity’s sake as this would require keeping track of which users have undelegated how much
and would require a more complex implementation.
