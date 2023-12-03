# ChainlinkedKeydonixOracleMainAsset Smart Contract Technical Overview

## Contract Overview
`ChainlinkedKeydonixOracleMainAsset` is a Solidity smart contract for calculating USD and ETH prices of tokens. It integrates with UniswapV2 for liquidity data and leverages the Keydonix Oracle for price feeds.

## Key Features

### 1. Oracle Integrations
- Utilizes Keydonix Oracle for fetching asset prices.
- Integrates with Chainlink for ETH to USD conversion.
- Interacts with Uniswap V2 Factory for pair information.

### 2. Price Calculation
- **assetToUsd**: Computes the USD price of a given amount of an asset using UniswapV2's time-weighted average prices (TWAP).
- **assetToEth**: Determines the ETH price of a specified asset amount using the Keydonix Oracle.

### 3. Merkle Proofs
- The contract uses Merkle proofs to verify the integrity and authenticity of the data fetched from external sources.

### 4. SafeMath Library
- Incorporates SafeMath for safe arithmetic operations, guarding against overflows.

### 5. Helper Libraries
- **UniswapOracle**: Contains functions for interacting with Uniswap V2 pairs.
- **Rlp, MerklePatriciaVerifier, BlockVerifier**: Libraries for handling various cryptographic and data processing tasks.

### 6. Contract Dependencies
- Requires UniswapV2 Factory, Oracle Registry, and WETH address for proper functionality.

### 7. Min and Max Block Range
- Defines minimum and maximum block range constraints for oracle data validation.

### 8. Price Feed Validation
- Ensures that the price data is within a valid block range and properly verified using cryptographic proofs.

## Additional Information
- The contract is designed to be compatible with Ethereum-based tokens.
- It primarily targets tokens with sufficient liquidity on Uniswap V2.

## Conclusion
`ChainlinkedKeydonixOracleMainAsset` is an oracle contract that provides reliable and secure price feeds for Ethereum-based tokens using a combination of UniswapV2's TWAP and Keydonix Oracle data, enhanced with Chainlink's ETH to USD price conversion.
