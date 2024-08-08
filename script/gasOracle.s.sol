// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {gasOracle} from "../src/gasOracle.sol";

contract GasOracleScript is Script {
    gasOracle public chainOracle;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    address immutable _arbRouter = 0x141fa059441E0ca23ce184B6A78bafD2A517DdE8;
    address immutable _opRouter = 0x3206695CaE29952f4b0c22a169725a865bc8Ce0f;

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
        chainOracle = new gasOracle(_opRouter);
        console.log("Deployed contract address:", address(chainOracle));

        vm.stopBroadcast();
    }
}
