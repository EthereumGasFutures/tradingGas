// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {trader} from "../src/trader.sol";
import {erc20init} from "../src/erc20init.sol";
import {erc20init} from "../src/erc20init.sol";

contract TraderScript is Script {
    trader public traderContract;
    erc20init public erc20base;
    erc20init public erc20arb;
    erc20init public erc20op;

    //arb, op, base
    uint64[] chainSelectors = [4949039107694359620, 3734403246176062136,  15971525489660198786];
    address[] gasOracleContracts = [0x4ec5b3e934000C184e6c3Dda2baEEA5e9141ccC3, 0x7Fbc0146036526AB1c7B8bcD2BA8b03253646f31, 0xD18A967cB98e2f249c156D6cdA1Ae6D675a46a4F];

    address baseOracleContract = 0x1410032621Daa7f188dbdc22021292d3F101846a;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address derivedAddress = vm.addr(deployerPrivateKey);
        console.log("Derived address from private key:", derivedAddress);

        traderContract = new trader(derivedAddress, baseOracleContract);
        traderContract.setBaseOracleContract(baseOracleContract);

        erc20base = new erc20init(address(traderContract), "baseGIX", "Gas Token on Base");
        erc20arb = new erc20init(address(traderContract), "arbGIX", "Gas Token on Arbitrum");
        erc20op = new erc20init(address(traderContract), "opGIX", "Gas Token on Optimism");

        traderContract.setTokenAddress(15971525489660198786, address(erc20base));
        traderContract.setTokenAddress(4949039107694359620, address(erc20arb));
        traderContract.setTokenAddress(3734403246176062136, address(erc20op));

        console.log("Trader contract: ", address(traderContract));

        vm.stopBroadcast();
    }
}
