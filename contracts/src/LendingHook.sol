// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/BaseHook.sol";
import "forge-std/Test.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta, toBalanceDelta, BalanceDeltaLibrary} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {CurrencySettler} from "v4-core/test/utils/CurrencySettler.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {TickBitmap} from "v4-core/src/libraries/TickBitmap.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {Pool} from "v4-core/src/libraries/Pool.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {PoolGetters} from "lib/v4-periphery/contracts/libraries/PoolGetters.sol";

contract LendingHook is BaseHook {
    bytes constant ZERO_BYTES = new bytes(0);


    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;
    using StateLibrary for IPoolManager;
    using PoolGetters for IPoolManager;
    using TickBitmap for mapping(int16 => uint256);

    bool public lock = false;
    PoolKey public syntheticPoolKey;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: true,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: true,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: true,
            afterRemoveLiquidityReturnDelta: true
        });
    }

    function convertSqrtPriceX96ToPrice(
        uint160 sqrtPriceX96
    ) public pure returns (uint256) {
        // Convert the sqrtPriceX96 to a regular price using Uniswap's formula.
        uint256 price = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) >> 96;
        return price;
    }

    // TODO: Add owner
    function addSyntheticPoolKey(PoolKey calldata poolKey) external {
        syntheticPoolKey = poolKey;
    }

    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
    external
    override
    returns (bytes4, BeforeSwapDelta, uint24)
    {
        // TODO: Mint synthetic A

        // TODO: Swap tokens in synthetic pool

        // TODO: Burn synthetic B

        // TODO: Add liquidity to this pool from lender
        // data of synthetic swap
        lockCall();
        lockCall();

//        (uint160 sqrtPriceX96, int24 tickCurrent,,) = manager.getSlot0(key.toId());
////    (uint128 liquidityGross, int128 liquidityNet,,) = manager.getTickInfo(key.toId(), tickCurrent);
////        (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) = manager.getFeeGrowthInside(key.toId(), -1, 0);
//    console2.log("-----------------------");
//    console2.log("Current ticker", tickCurrent);
//    console2.log("Liquidity", manager.getNetLiquidityAtTick(key.toId(), tickCurrent));
////    console2.log("Liquidity Gross from current ticker", liquidityGross);
////    console2.log("Liquidity Net from current ticker", liquidityNet);
//    console2.log("Tick from price", TickMath.getTickAtSqrtPrice(sqrtPriceX96));
//    console2.log("Price", sqrtPriceX96);
//    (int24 nextTicker,) = manager.getNextInitializedTickWithinOneWord(key.toId(), tickCurrent, key.tickSpacing, true);
//    (uint128 nextLiquidityGross, int128 nextLiquidityNet,,) = manager.getTickInfo(key.toId(), nextTicker);
//    console2.log("Next ticker", nextTicker);
//    console2.log("Liquidity", manager.getNetLiquidityAtTick(key.toId(), nextTicker));
//    console2.log("Liquidity Gross from next ticker", nextLiquidityGross);
//    console2.log("Liquidity Net from next ticker", nextLiquidityNet);
//    console2.log("-----------------------");

//        (BalanceDelta result,) = manager.modifyLiquidity(
//            key,
//            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 6 ether, 0),
//            new bytes(0)
//        );
//
//        key.currency0.settle(manager, address(this), uint128(-result.amount0()), false);
//        key.currency1.settle(manager, address(this), uint128(-result.amount1()), false);


        unlockCall();

        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function lockCall() internal {
        lock = true;
    }

    function unlockCall() internal {
        lock = false;
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata bla,
        BalanceDelta delta,
        bytes calldata bla2
    ) external override returns (bytes4, BalanceDelta) {
        if(lock) {
            return (BaseHook.afterAddLiquidity.selector, BalanceDeltaLibrary.ZERO_DELTA);
        }

        manager.take(key.currency0, address(this), uint128(-delta.amount0()));
        manager.take(key.currency1, address(this), uint128(-delta.amount1()));
        return (BaseHook.afterAddLiquidity.selector, toBalanceDelta(-delta.amount0(), -delta.amount1()));
    }

    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata bla,
        BalanceDelta delta,
        bytes calldata bla2
    ) external override returns (bytes4, BalanceDelta) {
        // TODO: Withdraw and burn from the synthetic pool

        // TODO: + transfer with fee (calculated from synthetic)
        manager.take(key.currency0, address(sender), uint128(delta.amount0()));
        manager.take(key.currency1, address(sender), uint128(delta.amount1()));

        return (BaseHook.beforeRemoveLiquidity.selector, toBalanceDelta(delta.amount0(), delta.amount1()));
    }
}
