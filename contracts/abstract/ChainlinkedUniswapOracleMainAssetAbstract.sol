// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).
*/
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

import "./UniswapOracleAbstract.sol";


/**
 * @title ChainlinkedUniswapOracleMainAssetAbstract
 * @author Unit Protocol: Artem Zakharov (az@unit.xyz), Alexander Ponomorev (@bcngod)
 **/
abstract contract ChainlinkedUniswapOracleMainAssetAbstract is UniswapOracleAbstract {

    address public WETH;

    function assetToEth(
        address asset,
        uint amount,
        UniswapOracle.ProofData memory proofData
    ) public virtual view returns (uint) {}

    function ethToUsd(uint ethAmount) public virtual view returns (uint) {}
}
