// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {trader} from "../src/trader.sol";

contract TraderScript is Script {
    trader public traderContract;

    //arb, op, base
    uint64[] chainSelectors = [4949039107694359620, 3734403246176062136,  15971525489660198786];
    address[] gasOracleContracts = [0x4ec5b3e934000C184e6c3Dda2baEEA5e9141ccC3, address(0), 0xD18A967cB98e2f249c156D6cdA1Ae6D675a46a4F];

    address baseOracleContract;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);


        traderContract = new trader(msg.sender);
        traderContract.setBaseOracleContract(baseOracleContract);



        vm.stopBroadcast();
    }
}
