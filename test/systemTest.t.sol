// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";
import {gasOracle} from "../src/gasOracle.sol";
import "chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";

contract systemTest is Test {
    baseGeneralOracle public generalOracle;
    gasOracle public localGasOracleContract;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    uint64 arbChainSelector = 4949039107694359620;
    uint64 modeChainSelector = 7264351850409363825;
    uint64 opChainSelector = 3734403246176062136;

    address public gasOracleContractARB = 0x4ec5b3e934000C184e6c3Dda2baEEA5e9141ccC3;

    function setUp() public {
        generalOracle = new baseGeneralOracle(_baseRouter, msg.sender);
        localGasOracleContract = new gasOracle();
        generalOracle.setGasOracleAddress( arbChainSelector, address(gasOracleContractARB) );
        
        vm.deal(msg.sender, 10 ether);
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

    function testGetGasPrice() public {
        uint256 fee = generalOracle.estimateFee(arbChainSelector);
        generalOracle.requestGasPrice{value: fee}(arbChainSelector);

        // Simulate the gas price retrieval on Arbitrum
        uint256 arbitrumGasPrice = 50 gwei; // Example gas price
        
        // Manually create and send the CCIP message
        Client.Any2EVMMessage memory message = Client.Any2EVMMessage({
            messageId: bytes32(0), // You can generate a random messageId if needed
            sourceChainSelector: arbChainSelector,
            sender: abi.encode(address(gasOracleContractARB)),
            data: abi.encode(arbitrumGasPrice),
            destTokenAmounts: new Client.EVMTokenAmount[](0)
        });

        // Manually call ccipReceive to simulate message receipt
        generalOracle.ccipReceive(message);

        // Now check the updated gas price
        uint256 receivedGasPrice = generalOracle.getGasPrice(arbChainSelector);
        console.log("Gas price received from ARB:", receivedGasPrice);
        assertEq(receivedGasPrice, arbitrumGasPrice, "Gas price mismatch");
    }
}
