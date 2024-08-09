// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";
import {gasOracle} from "../src/gasOracle.sol";
import "chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import "../src/interfaces.sol";
import "../src/erc20init.sol";
import "../src/trader.sol";

contract systemTest is Test {
    baseGeneralOracle public generalOracle;
    gasOracle public localGasOracleContract;
    erc20init public erc20base;
    erc20init public erc20arb;
    erc20init public erc20op;
    trader public traderContract; 

    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    address immutable _arbRouter = 0x141fa059441E0ca23ce184B6A78bafD2A517DdE8;
    address immutable _opRouter = 0x3206695CaE29952f4b0c22a169725a865bc8Ce0f;

    uint64 arbChainSelector = 4949039107694359620;
    uint64 opChainSelector = 3734403246176062136;
    uint64 baseChainSelector = 15971525489660198786;

    address public gasOracleContractARB = 0x1410032621Daa7f188dbdc22021292d3F101846a;
    address public gasOracleContractBASE = 0xeD257dcdC020d45F5B847aD6dD2AB7Cc07a510DD;
    address public gasOracleContractOP = 0xF5B298825B38DA0F5825e339f24F2E35A6A18757;

    address owner;
    address baseOracleContract = 0x1410032621Daa7f188dbdc22021292d3F101846a;

    function setUp() public {
        owner = msg.sender;
        generalOracle = new baseGeneralOracle(_baseRouter, owner);
        traderContract = new trader(owner, address(generalOracle));

        erc20base = new erc20init(address(traderContract), "baseGIX", "Gas Token on Base");
        erc20arb = new erc20init(address(traderContract), "arbGIX", "Gas Token on Arbitrum");
        erc20op = new erc20init(address(traderContract), "opGIX", "Gas Token on Optimism");

        localGasOracleContract = new gasOracle(_baseRouter);
        generalOracle.setGasOracleAddress( arbChainSelector, address(gasOracleContractARB) );
        generalOracle.setGasOracleAddress( opChainSelector, address(gasOracleContractOP) );
        
        vm.prank(owner);
        traderContract.setTokenAddress(15971525489660198786, address(erc20base));
        vm.prank(owner);
        traderContract.setTokenAddress(4949039107694359620, address(erc20arb));
        vm.prank(owner);
        traderContract.setTokenAddress(3734403246176062136, address(erc20op));

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
        generalOracle.getOldAndRequestNewGasPrice{value: fee}(arbChainSelector);

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
        uint256 receivedGasPrice = generalOracle.getOldGasPrice(arbChainSelector);
        console.log("Gas price received from ARB:", receivedGasPrice);
        assertEq(receivedGasPrice, arbitrumGasPrice, "Gas price mismatch");
    }

    function testRealGasPrices() public view {
        uint256 fee = generalOracle.estimateFee(arbChainSelector);
        uint256 gasArbitrum = IBaseGeneralOracle( baseOracleContract ).getAvailableGasPrice(arbChainSelector);
        fee = generalOracle.estimateFee(opChainSelector);
        uint256 gasOP = IBaseGeneralOracle( baseOracleContract ).getAvailableGasPrice(opChainSelector);

        console.log("Gas arb: ", gasArbitrum);
        console.log("Gas op: ", gasOP);

        assertTrue(gasArbitrum > 0, "Either first time, or invalid");
        assertTrue(gasOP > 0, "Either first time, or invalid");

    }

    function testTrading() public {

        vm.prank(owner);
        traderContract.claimInitialTokens();

        uint256 amountBase = IERC20( traderContract.localTokenAddresses(baseChainSelector) ).balanceOf(owner);
        vm.prank(owner);
        traderContract.swapTokens(baseChainSelector, opChainSelector, amountBase / 2 );
        uint256 amountOP = IERC20( traderContract.localTokenAddresses(opChainSelector) ).balanceOf(owner);
        vm.prank(owner);
        traderContract.swapTokens(opChainSelector, arbChainSelector, amountOP / 2);
        uint256 amountARB = IERC20( traderContract.localTokenAddresses(arbChainSelector) ).balanceOf(owner);

        assertGt( amountBase, 0, "Cannot be zero (Base)" );
        assertGt( amountOP, 0, "Cannot be zero (OP)" );
        assertGt( amountARB, 0, "Cannot be zero (ARB)" );

    }

}
