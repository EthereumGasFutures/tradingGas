// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";

contract BaseGeneralOracleScript is Script {
    baseGeneralOracle public generalOracle;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;

    uint64 arbChainSelector = 4949039107694359620;
    uint64 opChainSelector = 3734403246176062136;

    address public gasOracleContractARB = 0x1410032621Daa7f188dbdc22021292d3F101846a;
    address public gasOracleContractBASE = 0xeD257dcdC020d45F5B847aD6dD2AB7Cc07a510DD;
    address public gasOracleContractOP = 0xF5B298825B38DA0F5825e339f24F2E35A6A18757;

    function setUp() public {
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);
        generalOracle = new baseGeneralOracle(_baseRouter, msg.sender);
        generalOracle.setGasOracleAddress( arbChainSelector, address(gasOracleContractARB) );
        generalOracle.setGasOracleAddress( opChainSelector, address(gasOracleContractOP) );

        vm.stopBroadcast();
    }
}
