// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";

contract BaseGeneralOracleScript is Script {
    baseGeneralOracle public generalOracle;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);
        generalOracle = new baseGeneralOracle(_baseRouter, msg.sender);

        vm.stopBroadcast();
    }
}
