// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {trading} from "../src/trading.sol";

contract TradingScript is Script {
    trading public tradingSystem;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);
        tradingSystem = new trading(msg.sender);

        vm.stopBroadcast();
    }
}
