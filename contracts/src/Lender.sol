//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.24;
//
//struct ModifyLiquidityParams {
//    // the lower and upper tick of the position
//    int24 tickLower;
//    int24 tickUpper;
//    // how to modify the liquidity
//    int256 liquidityDelta;
//}
//
//
//contract Lender {
//
//    address constant hook;
//    // modifyLiquidity onlyHook
//        // pool
//
//    modifier onlyHook() {
//        require(msg.sender == address(hook));
//        _;
//    }
//
//    function modifyLiquidity(
//        address sender,
//        PoolKey calldata key,
//        IPoolManager.ModifyLiquidityParams calldata params
//    ) external {
//
//
//
//        manager.take(key.currency0, address(this), uint128(-delta.amount0()));
//        manager.take(key.currency1, address(this), uint128(-delta.amount1()));
//        return (BaseHook.afterAddLiquidity.selector, toBalanceDelta(-delta.amount0(), -delta.amount1()));
//    }
//}
