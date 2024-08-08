// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {baseGeneralOracle} from "../src/baseGeneralOracle.sol";
import "../src/interfaces.sol";

contract BaseGeneralOracleInitScript is Script {
    baseGeneralOracle public generalOracle;
    address immutable _baseRouter = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
    address baseOracleContract = 0xF5B298825B38DA0F5825e339f24F2E35A6A18757;

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

        IBaseGeneralOracle( baseOracleContract ).setGasOracleAddress( arbChainSelector, address(gasOracleContractARB) );
        IBaseGeneralOracle( baseOracleContract ).setGasOracleAddress( opChainSelector, address(gasOracleContractOP) );

        uint256 fee = IBaseGeneralOracle( baseOracleContract ).estimateFee(arbChainSelector);
        uint256 gasArbitrum = IBaseGeneralOracle( baseOracleContract ).getOldAndRequestNewGasPrice{value: fee}(arbChainSelector);
        fee = IBaseGeneralOracle( baseOracleContract ).estimateFee(opChainSelector);
        uint256 gasOP = IBaseGeneralOracle( baseOracleContract ).getOldAndRequestNewGasPrice{value: fee}(opChainSelector);

        console.log("Gas arb: ", gasArbitrum);
        console.log("Gas op: ", gasOP);

        vm.stopBroadcast();
    }
}
