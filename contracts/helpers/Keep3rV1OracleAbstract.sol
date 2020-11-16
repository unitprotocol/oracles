// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).
*/
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

abstract contract Keep3rV1OracleAbstract {
    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }
    mapping(address => Observation[]) public observations;

    function current(address tokenIn, uint amountIn, address tokenOut) external virtual view returns (uint amountOut);
    function observationLength(address pair) external virtual view returns (uint);
    function lastObservation(address pair) public virtual view returns (Observation memory);
}
