// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {gasOracle} from "../src/gasOracle.sol";

contract GasOracleScript is Script {
    gasOracle public chainOracle;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);
        chainOracle = new gasOracle();
        console.log( "Contract address: ", address(chainOracle) );
        
        vm.stopBroadcast();
    }
}
