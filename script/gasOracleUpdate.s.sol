// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";
import "../src/interfaces.sol";

contract GasOracleUpdateScript is Script {
    baseGeneralOracle public generalOracle;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    address baseOracleContract = 0x3CD1Ea9586D60740c7Ab9e62CA74833090429E39;

    uint64 arbChainSelector = 4949039107694359620;
    uint64 opChainSelector = 3734403246176062136;

    address public gasOracleContractBASE = 0x9192613b171240931fa516d5A414a42C63C8bA45;
    address public gasOracleContractARB = 0x59EAD96f7D092963c8afa46aa6ce7ce75097D9D2;
    address public gasOracleContractOP = 0x610A4A6A9Bf0DC2B261b51B8d349286CC98Dac02;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);

        vm.stopBroadcast();
    }
}
