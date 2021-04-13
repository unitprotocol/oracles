pragma experimental ABIEncoderV2;
import { UniswapOracle } from  '@keydonix/uniswap-oracle-contracts/source/UniswapOracle.sol';

interface IKeydonixOracleUsd {

    // returns Q112-encoded value
    function assetToUsd(address asset, uint amount, UniswapOracle.ProofData calldata proofData) external view returns (uint);
}