// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import "chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract gasOracle {
    uint256 public lastGasPrice;
    uint256 public lastTimestamp;
    IRouterClient private i_router;
    uint64 baseChainSelector = 15971525489660198786;
    address sourceOracleAddress = 0x1410032621Daa7f188dbdc22021292d3F101846a;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    bool native = true;

    // Set the router address and the source chain's oracle address in the constructor
    constructor(address router) {
        if (router != _baseRouter) {
            i_router = IRouterClient(router);
            native = false;
        }
    }

    function getGasPrice() public returns (uint256) {
        lastGasPrice = block.basefee;
        lastTimestamp = block.timestamp;
        if( !native ) {
            // Send the gas price back to the source chain
            Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
                receiver: abi.encode(sourceOracleAddress),
                data: abi.encodeWithSignature("ccipReceive(uint256)", lastGasPrice),
                tokenAmounts: new Client.EVMTokenAmount[](0),
                extraArgs: Client._argsToBytes(
                    Client.EVMExtraArgsV1({gasLimit: 200_000})
                ),
                feeToken: address(0) // Use native token (ETH) for fees
            });

            uint256 fee = i_router.getFee(baseChainSelector, message);
            i_router.ccipSend{value: fee}(baseChainSelector, message);

        }
        return lastGasPrice;
    }
}