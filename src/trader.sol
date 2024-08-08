// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

//Contract to update the gas price and return it. It is built as a transaction that modify the state because some EVM return zero if there is no transactions.
contract trader is Ownable{
    
    uint64 baseChainSelector = 15971525489660198786;
    address public baseOracleContract;

    mapping(uint64 => address) public localTokenAddresses;
    mapping(uint64 => address) public gasOracleContract;

    constructor(address newOwner) Ownable(newOwner) {}

    function setTokenAddress(uint64 chainSelector, address tokenAddress) public onlyOwner {
        localTokenAddresses[chainSelector] = tokenAddress;
    }

    function setGasOracleContract(uint64 chainSelector, address oracleAddress) public onlyOwner {
        gasOracleContract[chainSelector] = oracleAddress;
    }

    function setBaseOracleContract(address newBaseOracleContract) public onlyOwner {
        baseOracleContract = newBaseOracleContract;
    }

}