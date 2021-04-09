// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).
*/
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "../helpers/SafeMath.sol";
import "../helpers/AggregatorInterface.sol";
import "../helpers/Keep3rV1OracleAbstract.sol";
import "../helpers/IUniswapV2Factory.sol";
import "../helpers/UniswapV2Library.sol";
import "../helpers/UniswapV2OracleLibrary.sol";
import "../helpers/IOracleRegistry.sol";
import "../helpers/IOracleUsd.sol";
import "../helpers/IOracleEth.sol";


/**
 * @title ChainlinkedKeep3rV1OracleMainAsset
 * @dev Calculates the USD price of desired tokens
 **/
contract ChainlinkedKeep3rV1OracleMainAsset is IOracleUsd {
    using SafeMath for uint;

    uint public immutable minObservationTimeBack = 1.5 hours;
    uint public immutable maxObservationTimeBack = 2.5 hours;

    uint public immutable Q112 = 2 ** 112;

    uint public immutable ETH_USD_DENOMINATOR = 1e8;

    address public immutable WETH;

    IOracleRegistry public immutable oracleRegistry;

    Keep3rV1OracleAbstract public immutable keep3rV1Oracle;

    IUniswapV2Factory public immutable uniswapFactory;

    constructor(
        IUniswapV2Factory _uniFactory,
        Keep3rV1OracleAbstract _keep3rV1Oracle,
        IOracleRegistry _oracleRegistry
    )
        public
    {
        require(address(_uniFactory) != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(address(_keep3rV1Oracle) != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(address(_oracleRegistry) != address(0), "Unit Protocol: ZERO_ADDRESS");

        uniswapFactory = _uniFactory;
        keep3rV1Oracle = _keep3rV1Oracle;
        oracleRegistry = _oracleRegistry;
        WETH = IOracleRegistry(_oracleRegistry).WETH();
    }

    /**
     * @notice {Token}/WETH pair must be registered on Uniquote
     * @param asset The token address
     * @param amount Amount of tokens
     * @return Q112-encoded price of asset amount in USD
     **/
    function assetToUsd(address asset, uint amount) public override view returns (uint) {
        return IOracleEth(oracleRegistry.oracleByAsset(oracleRegistry.WETH())).ethToUsd(assetToEth(asset, amount));
    }

    /**
     * @notice {asset}/WETH pair must be registered at Keep3rV1Oracle
     * @param asset The token address
     * @param amount Amount of tokens
     * @return Q112-encoded price of asset amount in ETH
     **/
    function assetToEth(address asset, uint amount) public view returns (uint) {
        if (amount == 0) {
            return 0;
        }
        if (asset == WETH) {
            return amount.mul(Q112);
        }
        return keep3rCurrent(asset, amount);
    }

    /**
     * @notice {asset}/WETH price feed from uniquote.finance, see for more info: https://docs.uniquote.finance/
     * @param tokenIn The token in address
     * @param amountIn Amount of tokens in
     * returns Q112-encoded current asset price in ETH
     **/
    function keep3rCurrent(address tokenIn, uint amountIn) public view returns (uint amountOut) {
        address pair = UniswapV2Library.pairFor(address(uniswapFactory), tokenIn, WETH);
        (address token0,) = UniswapV2Library.sortTokens(tokenIn, WETH);
        uint observationLength = keep3rV1Oracle.observationLength(pair);
        require(observationLength > 1, "Unit Protocol: NOT_ENOUGH_OBSERVATIONS");
        uint observationIndex = observationLength - 1;
        uint timestampObs; uint price0CumulativeObs; uint price1CumulativeObs;
        (timestampObs, price0CumulativeObs, price1CumulativeObs) = keep3rV1Oracle.observations(pair, observationIndex);
        (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        while (block.timestamp - timestampObs < minObservationTimeBack) {
            observationIndex -= 1;
            (timestampObs, price0CumulativeObs, price1CumulativeObs) = keep3rV1Oracle.observations(pair, observationIndex);
            if (block.timestamp - timestampObs > maxObservationTimeBack) break;
        }
        require(block.timestamp - timestampObs <= maxObservationTimeBack, "Unit Protocol: STALE_PRICES");
        uint timeElapsed = block.timestamp - timestampObs;
        if (token0 == tokenIn) {
            return computeAmountOut(price0CumulativeObs, price0Cumulative, timeElapsed, amountIn);
        } else {
            return computeAmountOut(price1CumulativeObs, price1Cumulative, timeElapsed, amountIn);
        }
    }

    // returns Q112-encoded value
    function computeAmountOut(
        uint priceCumulativeStart, uint priceCumulativeEnd,
        uint timeElapsed, uint amountIn
    ) private pure returns (uint) {
        // overflow is desired
        uint avgPrice = (priceCumulativeEnd - priceCumulativeStart) / timeElapsed;
        return avgPrice.mul(amountIn);
    }
}
