// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SyntheticToken is ERC20, Ownable {
    address constant LENDING_POOL_ADDRESS = 0x2900000000000000000000000000000000000029;

    constructor(
        string memory name,
        uint256 initialSupply
    ) ERC20(name, "SYNTH") Ownable(msg.sender) {
        _mint(LENDING_POOL_ADDRESS, initialSupply);
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(LENDING_POOL_ADDRESS, amount);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(LENDING_POOL_ADDRESS, amount);
    }
}