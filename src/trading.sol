// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import "chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract trading {
    using Client for Client.EVM2AnyMessage;

    IRouterClient public immutable i_router;
    mapping(uint64 => address) public gasOracleAddresses;
    mapping(uint64 => uint256) public chainGasPrices;
    mapping(bytes32 => uint64) public messageIdToChainSelector;

    event GasPriceRequestSent(uint64 chainSelector, bytes32 messageId);
    event GasPriceUpdated(uint64 chainSelector, uint256 gasPrice);

    constructor(address _router) {
        i_router = IRouterClient(_router);
    }

    function setGasOracleAddress(uint64 chainSelector, address gasOracleAddress) external {
        gasOracleAddresses[chainSelector] = gasOracleAddress;
    }

    function requestGasPrice(uint64 chainSelector) external payable {
        require(gasOracleAddresses[chainSelector] != address(0), "Gas oracle not set for this chain");

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(gasOracleAddresses[chainSelector]),
            data: abi.encodeWithSignature("getGasPrice()"),
            tokenAmounts: new Client.TokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false})
            ),
            feeToken: address(0) // Use native gas token (ETH)
        });

        uint256 fee = i_router.getFee(chainSelector, message);
        require(msg.value >= fee, "Insufficient ETH for fees");

        bytes32 messageId = i_router.ccipSend{value: fee}(chainSelector, message);
        messageIdToChainSelector[messageId] = chainSelector;

        // Refund excess ETH
        if (msg.value > fee) {
            payable(msg.sender).transfer(msg.value - fee);
        }

        emit GasPriceRequestSent(chainSelector, messageId);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal {
        uint64 chainSelector = message.sourceChainSelector;
        (uint256 gasPrice) = abi.decode(message.data, (uint256));
        
        chainGasPrices[chainSelector] = gasPrice;
        emit GasPriceUpdated(chainSelector, gasPrice);
    }

    function getGasPrice(uint64 chainSelector) external view returns (uint256) {
        return chainGasPrices[chainSelector];
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}