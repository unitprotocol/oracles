// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).
*/
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "../helpers/SafeMath.sol";
import "../helpers/IOracleRegistry.sol";
import "../helpers/IOracleEth.sol";
import "../helpers/IKeydonixOracleEth.sol";
import "../helpers/IKeydonixOracleUsd.sol";
import { UniswapOracle, IUniswapV2Pair } from  '@keydonix/uniswap-oracle-contracts/source/UniswapOracle.sol';
import "../helpers/AggregatorInterface.sol";
import "../helpers/IUniswapV2Factory.sol";


/**
 * @title ChainlinkedKeydonixOracleMainAsset
 * @dev Calculates the USD price of desired tokens
 **/
contract ChainlinkedKeydonixOracleMainAsset is UniswapOracle, IKeydonixOracleEth, IKeydonixOracleUsd {
    using SafeMath for uint;

    uint8 public constant MIN_BLOCKS_BACK = uint8(100);

    uint8 public constant MAX_BLOCKS_BACK = uint8(255);

    uint public constant ETH_USD_DENOMINATOR = 1e8;

    uint public constant Q112 = 2 ** 112;

    IUniswapV2Factory public uniswapFactory;

    IOracleRegistry public oracleRegistry;

    address public immutable WETH;

    constructor(
        IUniswapV2Factory uniFactory,
        IOracleRegistry _oracleRegistry
    )
        public
    {
        require(address(uniFactory) != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(address(_oracleRegistry) != address(0), "Unit Protocol: ZERO_ADDRESS");

        uniswapFactory = uniFactory;
        WETH = _oracleRegistry.WETH();
        oracleRegistry = _oracleRegistry;
    }

    /**
     * @notice USD token's rate is UniswapV2 Token/WETH pool's average time weighted price between proofs' blockNumber and current block number
     * @notice Merkle proof must be in range [MIN_BLOCKS_BACK ... MAX_BLOCKS_BACK] blocks ago
     * @notice {Token}/WETH pair must exists on Uniswap
     * @param asset The token address
     * @param amount Amount of tokens
     * @param proofData Merkle proof data
     * @return Q112-encoded price of tokens in USD
     **/
    function assetToUsd(address asset, uint amount, UniswapOracle.ProofData memory proofData) public override view returns (uint) {
        uint priceInEth = assetToEth(asset, amount, proofData);
        return IOracleEth(oracleRegistry.oracleByAsset(WETH)).ethToUsd(priceInEth);
    }

    /**
     * @notice USD token's rate is UniswapV2 Token/WETH pool's average price between proof's blockNumber and current block number
     * @notice Merkle proof must be in range [MIN_BLOCKS_BACK ... MAX_BLOCKS_BACK] blocks ago
     * @notice {Token}/WETH pair must be registered on Uniswap
     * @param asset The token address
     * @param amount Amount of tokens
     * @param proofData Merkle proof data
     * @return Q112-encoded price of asset in ETH
     **/
    function assetToEth(address asset, uint amount, UniswapOracle.ProofData memory proofData) public override view returns (uint) {
        if (amount == 0) { return 0; }
        if (asset == WETH) { return amount.mul(Q112); }
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapFactory.getPair(asset, WETH));
        require(address(pair) != address(0), "Unit Protocol: UNISWAP_PAIR_DOES_NOT_EXIST");
        (uint priceInEth, ) = getPrice(pair, WETH, MIN_BLOCKS_BACK, MAX_BLOCKS_BACK, proofData);
        return priceInEth.mul(amount);
    }
}
