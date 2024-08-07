// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import "chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "chainlink/contracts/src/v0.8/ccip/interfaces/IPriceRegistry.sol";

contract baseGeneralOracle is Ownable {
    using Client for Client.EVM2AnyMessage;

    IRouterClient immutable i_router;
    mapping(uint64 => address) public gasOracleAddresses;
    mapping(uint64 => uint256) public chainGasPrices;
    mapping(bytes32 => uint64) public messageIdToChainSelector;

    address priceFeedAddress = 0x6337a58D4BD7Ba691B66341779e8f87d4679923a;

    event GasPriceRequestSent(uint64 chainSelector, bytes32 messageId);
    event GasPriceUpdated(uint64 chainSelector, uint256 gasPrice);

    constructor(address _router, address newOwner) Ownable(newOwner) {
        i_router = IRouterClient(_router);
    }

    function setGasOracleAddress(uint64 chainSelector, address gasOracleAddress) external {
        gasOracleAddresses[chainSelector] = gasOracleAddress;
    }

    function getOldAndRequestNewGasPrice(uint64 chainSelector) external payable returns (uint256) {
        require(gasOracleAddresses[chainSelector] != address(0), "Gas oracle not set for this chain");

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(gasOracleAddresses[chainSelector]),
            data: abi.encodeWithSignature("getGasPrice()"),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            feeToken: address(0) // Use native token (ETH) for fees
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
        return chainGasPrices[chainSelector];
    }

    function ccipReceive(Client.Any2EVMMessage memory message) external {
        uint64 chainSelector = message.sourceChainSelector;
        (uint256 gasPrice) = abi.decode(message.data, (uint256));
        
        chainGasPrices[chainSelector] = gasPrice;
        emit GasPriceUpdated(chainSelector, gasPrice);
    }

    function getOldGasPrice(uint64 chainSelector) external view returns (uint256) {
        return chainGasPrices[chainSelector];
    }

    function getAvailableGasPrice(uint64 chainSelector) external view returns (uint256) {
        (, uint224 gasPrice) = IPriceRegistry(priceFeedAddress).getTokenAndGasPrices(0x4200000000000000000000000000000000000006, chainSelector);
        return uint256(uint112(gasPrice));
    }

    function estimateFee(uint64 chainSelector) public view returns (uint256){
        require(gasOracleAddresses[chainSelector] != address(0), "Gas oracle not set for this chain");

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(gasOracleAddresses[chainSelector]),
            data: abi.encodeWithSignature("getGasPrice()"),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            feeToken: address(0) // Use native token (ETH) for fees
        });

        uint256 fee = i_router.getFee(chainSelector, message);
        return fee;
    }

    function changePriceFeedAddress(address newPriceFeedAddress) public onlyOwner {
        priceFeedAddress = newPriceFeedAddress;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}