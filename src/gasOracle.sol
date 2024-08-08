// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Contract to update the gas price and return it. It is built as a transaction that modify the state because some EVM return zero if there is no transaction broadcasted
contract gasOracle {

    uint256 public lastGasPrice;
    uint256 public lastTimestamp;

    constructor() {}

    function getGasPrice() public returns (uint256) {
        lastGasPrice = block.basefee;
        lastTimestamp = block.timestamp;
        return lastGasPrice;
    }
    
}