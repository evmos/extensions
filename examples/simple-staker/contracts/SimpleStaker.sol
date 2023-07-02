// SPDX-License-Identifier: LGPL-v3
pragma solidity >=0.8.17;

import "../../../precompiles/stateful/Staking.sol";
import "../../../precompiles/stateful/Distribution.sol";

contract SimpleStaker {
    /// Methods to approve when calling approveRequiredMethods()
    string[] private stakingMethods = [MSG_DELEGATE];

    /// @dev Approves the required transactions for delegation and withdrawal of staking rewards transactions.
    /// @dev This creates a Cosmos Authorization Grants for the given methods.
    /// @dev This emits an Approval event.
    function approveRequiredMethods() public {
        bool success = STAKING_CONTRACT.approve(
            address(this),
            type(uint256).max,
            stakingMethods
        );
        require(success, "Failed to approve delegate method");
    }

    /// @dev stake a given amount of tokens.
    /// @dev This emits an Delegate event.
    /// @param _validatorAddr The address of the validator.
    /// @param _amount The amount of tokens to stake in aevmos.
    function stakeTokens(
        string memory _validatorAddr,
        uint256 _amount
    ) public {
        bool success = STAKING_CONTRACT.delegate(msg.sender, _validatorAddr, _amount);
        require(success, "Failed to stake tokens");
    }

    /// @dev withdraw delegation rewards from the specified validator address
    /// @dev This emits an WithdrawDelegatorRewards event.
    /// @param _validatorAddr The address of the validator.
    /// @return amount The amount of Coin withdrawn.
    function withdrawRewards(
        string memory _validatorAddr
    ) public returns (Coin[] memory amount) {
        return
            DISTRIBUTION_CONTRACT.withdrawDelegatorRewards(
                msg.sender,
                _validatorAddr
            );
    }

    /// ================================
    ///             QUERIES
    /// ================================

    /// @dev Returns the delegation information for a given validator for the msg sender.
    /// @param _validatorAddr The address of the validator.
    /// @return shares and balance. The delegation information for a given validator for the msg sender.
    function getDelegation(
        string memory _validatorAddr
    ) public view returns (uint256 shares, Coin memory balance) {
        return STAKING_CONTRACT.delegation(msg.sender, _validatorAddr);
    }

    /// @dev Returns the delegation rewards for a given validator for the msg sender.
    /// @param _validatorAddr The address of the validator.
    /// @return rewards The delegation rewards corresponding to the msg sender.
    function getDelegationRewards(
        string memory _validatorAddr
    ) public view returns (DecCoin[] memory rewards) {
        return
            DISTRIBUTION_CONTRACT.delegationRewards(msg.sender, _validatorAddr);
    }
}
