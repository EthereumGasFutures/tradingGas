// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {trading} from "../src/trading.sol";
import {gasOracle} from "../src/gasOracle.sol";

contract systemTest is Test {
    trading public tradingSystem;
    gasOracle public gasOracleContract;

    function setUp() public {
        tradingSystem = new trading(msg.sender);
        gasOracleContract = new gasOracle();
    }

    function testReadGasPrice() public {
        uint256 gasPrice = gasOracleContract.getGasPrice();
        console.log( "Gas price is: ", gasPrice );
        assertTrue(gasPrice > 0, "Gas price is invalid");
    }

}
