// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SyntheticToken is ERC20, Ownable {
    address constant SYNTH_HOOK_ADDRESS = 0x2900000000000000000000000000000000000029;

    constructor(
        string memory name,
        uint256 initialSupply
    ) ERC20(name, "SYNTH") Ownable(SYNTH_HOOK_ADDRESS) {
        _mint(SYNTH_HOOK_ADDRESS, initialSupply);
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(SYNTH_HOOK_ADDRESS, amount);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(SYNTH_HOOK_ADDRESS, amount);
    }
}