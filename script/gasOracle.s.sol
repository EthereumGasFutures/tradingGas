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
        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("Deployer address derived from private key:", deployerAddress);

        // Fetch the current nonce from the blockchain
        uint64 nonce = vm.getNonce(deployerAddress);
        console.log("Current nonce:", nonce);
        
        // Set the broadcast with the fetched nonce
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        chainOracle = new gasOracle();
        console.log("Deployed contract address:", address(chainOracle));

        vm.stopBroadcast();
    }
}
