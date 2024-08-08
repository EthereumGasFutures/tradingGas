// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";

contract BaseGeneralOracleScript is Script {
    baseGeneralOracle public generalOracle;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;

    uint64 arbChainSelector = 4949039107694359620;
    uint64 opChainSelector = 3734403246176062136;

    address public gasOracleContractARB = 0x4ec5b3e934000C184e6c3Dda2baEEA5e9141ccC3;
    address public gasOracleContractBASE = 0xD18A967cB98e2f249c156D6cdA1Ae6D675a46a4F;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);
        generalOracle = new baseGeneralOracle(_baseRouter, msg.sender);
        generalOracle.setGasOracleAddress( arbChainSelector, address(gasOracleContractARB) );

        vm.stopBroadcast();
    }
}
