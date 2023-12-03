# ChainlinkedKeydonixOraclePoolToken Smart Contract Technical Overview

## Contract Overview
`ChainlinkedKeydonixOraclePoolToken` is a Solidity smart contract designed for calculating the USD price of Uniswap LP tokens. It integrates with Chainlink and Keydonix oracles for price data. The oracle is resistant to flash loan and sandwich attacks. 

## Key Features

### 1. Oracle Integration
- Integrates with Keydonix Oracle for ETH price data.
- Uses Chainlink Oracle for converting ETH prices to USD.
- Interacts with Uniswap V2 Pair contracts for liquidity pool data.

### 2. Price Calculation
- **assetToUsd**: Computes the USD price of a given amount of Uniswap LP tokens. It uses a flashloan-resistant logic to determine the price based on the underlying assets.

### 3. Proof Data Handling
- Utilizes Merkle proofs for validating the integrity of data fetched from external sources.

### 4. SafeMath Library
- Employs SafeMath for arithmetic operations to prevent overflows.

### 5. Helper Libraries and Interfaces
- **UniswapOracle**: Contains functions for price calculation based on Uniswap V2 pairs.
- **Rlp, MerklePatriciaVerifier, BlockVerifier**: Libraries for cryptographic operations and data processing.

### 6. Contract Dependencies
- Depends on Oracle Registry, Vault Parameters, and WETH (Wrapped Ether) address.

### 7. Price Calculation Logic
- Implements a sophisticated mechanism to calculate the asset price considering possible flashloan attacks, ensuring reliable and secure pricing.

### 8. Oracle Selection
- Dynamically selects the appropriate oracle based on the asset and available oracle types registered in the Oracle Registry.

## Additional Information
- The contract is tailored for assets represented as Uniswap LP tokens.
- It ensures the authenticity and reliability of the price data using cryptographic proofs and checks against historical data.

## Conclusion
`ChainlinkedKeydonixOraclePoolToken` provides a secure and robust solution for determining the USD value of Uniswap LP tokens, utilizing a combination of Chainlink and Keydonix oracle data and implementing safeguards against flashloan-based price manipulation.
