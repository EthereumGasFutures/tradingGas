// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";
import {gasOracle} from "../src/gasOracle.sol";

contract systemTest is Test {
    baseGeneralOracle public generalOracle;
    gasOracle public gasOracleContract;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;

    function setUp() public {
        generalOracle = new baseGeneralOracle(_baseRouter, msg.sender);
        gasOracleContract = new gasOracle();
    }

    function testReadGasPrice() public {
        uint256 gasPrice = gasOracleContract.getGasPrice();
        console.log( "Gas price is: ", gasPrice );
        assertTrue(gasPrice > 0, "Gas price is invalid");
    }

}
