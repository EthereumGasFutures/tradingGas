// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IBaseGeneralOracle {
    function getOldAndRequestNewGasPrice(uint64 chainSelector) external payable returns (uint256);
    function getOldGasPrice(uint64 chainSelector) external view returns (uint256);
    function getAvailableGasPrice(uint64 chainSelector) external view returns (uint256);
    function estimateFee(uint64 chainSelector) external view returns (uint256);
    function setGasOracleAddress(uint64 chainSelector, address gasOracleAddress) external;
}

interface IERC20extended is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

