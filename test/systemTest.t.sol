// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";
import {gasOracle} from "../src/gasOracle.sol";

contract systemTest is Test {
    baseGeneralOracle public generalOracle;
    gasOracle public localGasOracleContract;
    address public gasOracleContractARB = 0x4ec5b3e934000C184e6c3Dda2baEEA5e9141ccC3;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    uint64 arbChainSelector = 4949039107694359620;
    uint64 modeChainSelector = 7264351850409363825;

    function setUp() public {
        generalOracle = new baseGeneralOracle(_baseRouter, msg.sender);
        localGasOracleContract = new gasOracle();
        generalOracle.setGasOracleAddress( arbChainSelector, address(gasOracleContractARB) );
    }

    function testReadGasPrice() public {
        uint256 gasPrice = localGasOracleContract.getGasPrice();
        console.log( "Gas price is: ", gasPrice );
        assertTrue(gasPrice > 0, "Gas price is invalid");
    }

    function testEstimateFee() public view {
        uint256 fee = generalOracle.estimateFee(arbChainSelector);
        console.log( "Estimated fee ARB: ", fee );
        assertTrue(fee > 0, "Fee is invalid");
    }


}
