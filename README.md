# Staking-Samos Contract Documentation

## Introduction

This document provides detailed information on how to interact with the Staking-Samos Contract, designed to allow users to stake ETH, receive receipt tokens, and opt-in for auto-compounding with rewards. The Contract is deployed to the Sepolia testnet network.

### Contract Overview

- **Contract Name:** StakingSamos
- **Token Name:** samsonajulorToken
- **Receipt Token Name:** samsonajulor-WETH
- **Annualized APR:** 14%
- **Conversion Ratio:** 1 ETH -> 10 Receipt Tokens
- **Auto-Compounding Fee:** 1% of WETH per month

### Interacting with the Contract

1. **Deposit ETH:**
   - Function: `deposit()`
   - Description: Deposit ETH to receive receipt tokens. The ETH is converted to WETH.
   - Example: `deposit({ value: amountInWei })`

2. **Opt-in for Auto-Compounding:**
   - Function: `optInAutoCompounding()`
   - Description: Opt-in for auto-compounding by paying a 1% fee. Auto-compounding will convert and stake your receipt tokens.
   - Example: `optInAutoCompounding()`

3. **Withdraw Staked Tokens:**
   - Function: `withdraw(uint256 amount)`
   - Description: Withdraw your staked tokens.
   - Example: `withdraw(amountInReceiptTokens)`

4. **Trigger Auto-Compounding:**
   - Function: `triggerAutoCompounding()`
   - Description: Anyone can trigger auto-compounding, receiving rewards from the accumulated fees.
   - Example: `triggerAutoCompounding()`

## Fees

- **Auto-Compounding Fee:** 1% of your WETH balance per month when opting in for auto-compounding.

## Events

The Staking-Samos Contract emits events to track various actions:

1. `Deposited(address indexed user, uint256 wethAmount, uint256 receiptTokens)` - Triggered when a user deposits ETH.
2. `AutoCompoundingOptIn(address indexed user, uint256 fee)` - Triggered when a user opts-in for auto-compounding.
3. `Withdrawn(address indexed user, uint256 amount)` - Triggered when a user withdraws staked tokens.
4. `AutoCompoundingTriggered(address indexed triggerer, uint256 reward)` - Triggered when someone triggers auto-compounding and receives a reward.
