// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./interfaces.sol";

//Contract to update the gas price and return it. It is built as a transaction that modify the state because some EVM return zero if there is no transactions.
contract trader is Ownable{
    
    uint64 baseChainSelector = 15971525489660198786;
    address public baseOracleContract;

    mapping(uint64 => address) public localTokenAddresses;
    mapping(uint64 => address) public gasOracleContract;
    mapping(address => uint256) initialMintedRegistry;

    constructor(address newOwner, address newBaseOracleContract) Ownable(newOwner) {
        baseOracleContract = newBaseOracleContract;
    }

    function claimInitialTokens() public {
        require( initialMintedRegistry[msg.sender] == 0, "User already claimed" );
        initialMintedRegistry[msg.sender] =  0.001 ether;
        IERC20extended(localTokenAddresses[baseChainSelector]).mint(msg.sender, 0.001 ether);
    }

    function swapTokens(uint64 chainSelectorFrom, uint64 chainSelectorTo, uint256 amountFrom) public returns (uint256) {
        address tokenAddressFrom = localTokenAddresses[chainSelectorFrom];
        address tokenAddressTo = localTokenAddresses[chainSelectorTo];

        require( IERC20extended(tokenAddressFrom).balanceOf(msg.sender) >= amountFrom, "User does not have enough funds" );
        uint256 gasPriceFrom = 0;
        if (chainSelectorFrom == baseChainSelector) {
            gasPriceFrom = block.basefee;
        } else {
            gasPriceFrom = IBaseGeneralOracle(baseOracleContract).getAvailableGasPrice(chainSelectorFrom);
        }

        uint256 gasPriceTo = 0;
        if (chainSelectorTo == baseChainSelector) {
            gasPriceTo = block.basefee;
        } else {
            gasPriceTo = IBaseGeneralOracle(baseOracleContract).getAvailableGasPrice(chainSelectorTo);
        }

        uint256 amountTo = ( amountFrom * gasPriceTo ) / gasPriceFrom;

        IERC20extended(tokenAddressFrom).burn(msg.sender, amountFrom);
        IERC20extended(tokenAddressTo).mint(msg.sender, amountTo);

        return amountTo;

    }

    function simulateSwapTokens(uint64 chainSelectorFrom, uint64 chainSelectorTo, uint256 amountFrom) public view returns (uint256) {

        uint256 gasPriceFrom = 0;
        if (chainSelectorFrom != baseChainSelector) {
            gasPriceFrom = block.basefee;
        } else {
            gasPriceFrom = IBaseGeneralOracle(baseOracleContract).getAvailableGasPrice(chainSelectorFrom);
        }

        uint256 gasPriceTo = 0;
        if (chainSelectorTo != baseChainSelector) {
            gasPriceTo = block.basefee;
        } else {
            gasPriceTo = IBaseGeneralOracle(baseOracleContract).getAvailableGasPrice(chainSelectorTo);
        }

        uint256 amountTo = amountFrom * gasPriceTo / gasPriceFrom;
        return amountTo;

    }

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