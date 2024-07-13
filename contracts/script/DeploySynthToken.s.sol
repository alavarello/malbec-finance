//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.19;
//
//import "forge-std/Script.sol";
//
//import {SyntheticToken} from "../src/SyntheticToken.sol";
//
//contract CounterScript is Script {
//    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
//
//    function setUp() public {}
//
//    function run() public {}
//
//    function deployTokens() internal returns (SyntheticToken token0, SyntheticToken token1) {
//        SyntheticToken tokenA = new SyntheticToken("USDC", 18);
//        SyntheticToken tokenB = new SyntheticToken("WIF", 18);
//        if (uint160(address(tokenA)) < uint160(address(tokenB))) {
//            token0 = tokenA;
//            token1 = tokenB;
//        } else {
//            token0 = tokenB;
//            token1 = tokenA;
//        }
//    }
//
//    function testLifecycle(
//    ) external {
//        (SyntheticToken token0, SyntheticToken token1) = deployTokens();
//        token0.mint(100_000 ether);
//        token1.mint(100_000 ether);
//    }
//}
