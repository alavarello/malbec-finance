// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SyntheticToken is ERC20, Ownable {
    constructor(
        string memory name,
        uint256 initialSupply
    ) ERC20(name, "SYNTH") Ownable(0x4444000000000000000000000000000000001583) {
        _mint(0x4444000000000000000000000000000000001583, initialSupply);
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(0x4444000000000000000000000000000000001583, amount);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(0x4444000000000000000000000000000000001583, amount);
    }
}
