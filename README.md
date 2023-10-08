# StakingSamos Contract Documentation

**License**: MIT License

**Solidity Version**: ^0.8.0

## Overview

The `StakingSamos` contract is designed for staking Ether (ETH) to earn receipt tokens with a specified annual APR and auto-compounding feature. Users can deposit ETH, opt-in for auto-compounding, and withdraw their staked ETH.

## Contract Details

- **Owner**: The owner of the contract has special privileges, such as triggering auto-compounding.

- **WETH Token Address**: The address of the Wrapped Ether (WETH) token contract.

- **Receipt Token**: An instance of the `ReceiptToken` contract used to mint receipt tokens.

- **Annual APR**: The annual interest rate (APR) in percentage (e.g., 14%).

- **Auto-compounding Fee Percentage**: The fee percentage charged for auto-compounding (e.g., 1%).

- **Auto-compounding Interval**: The time interval for auto-compounding (default is 30 days).

- **Precision**: Precision factor used in calculations.

## Structs

### User

- **addr**: Ethereum address of the user.
- **wethBalance**: User's WETH balance in the contract.
- **receiptTokenBalance**: User's receipt token balance in the contract.
- **optedInForAutoCompounding**: Indicates whether the user has opted in for auto-compounding.
- **lastAutoCompoundingTimestamp**: Timestamp of the last auto-compounding action.
- **isActive**: Indicates whether the user's account is active.

## Functions

### `constructor(address _wethTokenAddress)`

- Initializes the contract with the owner and WETH token address.
- Sets the default auto-compounding interval to 30 days.

### `deposit()`

- Allows users to deposit ETH and receive receipt tokens.
- Converts ETH to WETH.
- Calculates receipt tokens based on the annual APR.
- Updates user's balances and mints receipt tokens.

### `optInAutoCompounding()`

- Allows users to opt-in for auto-compounding.
- Checks if the user is active, hasn't already opted in, and has receipt tokens.
- Sets the user's opt-in status and updates the timestamp.

### `autoCompound(address addr)`

- Allows the owner to trigger auto-compounding for a specific user.
- Checks if the user is active, has opted in, and if the auto-compounding interval has passed.
- Charges a fee and converts receipt tokens to WETH.

### `withdrawWeth(uint256 amount)`

- Allows users to withdraw WETH from their balance in the contract.
- Checks if the user is active, has a positive amount to withdraw, and sufficient balance.
- Transfers the WETH to the user.

## Events

- `Deposited(address indexed user, uint256 wethAmount, uint256 receiptTokens)`: Emitted when a user deposits ETH.
- `AutoCompoundingOptIn(address indexed user)`: Emitted when a user opts in for auto-compounding.
- `AutoCompound(address indexed user, uint256 wethAmount, uint256 receiptTokens)`: Emitted when auto-compounding is triggered.
- `Withdrawn(address indexed user, uint256 amount)`: Emitted when a user withdraws WETH.

## Modifiers

- `onlyOwner()`: Ensures that only the contract owner can call certain functions.

## Errors

- Various custom error messages are defined for different failure conditions.

