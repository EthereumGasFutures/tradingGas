// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBaseGeneralOracle {
    function getOldAndRequestNewGasPrice(uint64 chainSelector) external payable returns (uint256);
    function getOldGasPrice(uint64 chainSelector) external view returns (uint256);
    function estimateFee(uint64 chainSelector) external view returns (uint256);
    function setGasOracleAddress(uint64 chainSelector, address gasOracleAddress) external;
}