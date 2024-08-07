// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract erc20init is ERC20, ERC20Burnable, Ownable {
    constructor(address ownerAddress) ERC20("Gas", "GIX")
        Ownable(ownerAddress) {
    }
}