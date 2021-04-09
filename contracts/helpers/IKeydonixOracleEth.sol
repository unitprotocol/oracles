pragma experimental ABIEncoderV2;
import { UniswapOracle } from  '@keydonix/uniswap-oracle-contracts/source/UniswapOracle.sol';

abstract contract IKeydonixOracleEth {

    // returns Q112-encoded value
    function assetToEth(address asset, uint amount, UniswapOracle.ProofData memory proofData) public virtual view returns (uint) { }
}