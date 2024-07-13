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
import {LiquidityAmounts} from "lib/v4-periphery/contracts/libraries/LiquidityAmounts.sol";
import {SyntheticHook} from "./SyntheticHook.sol";
import {SyntheticToken} from "./SyntheticToken.sol";
import {Lock} from "v4-core/src/libraries/Lock.sol";

contract LendingHook is BaseHook {
    bytes constant ZERO_BYTES = new bytes(0);
    uint256 MAX_INT = type(uint256).max;

    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;
    using StateLibrary for IPoolManager;
    using PoolGetters for IPoolManager;
    using TickBitmap for mapping(int16 => uint256);

    PoolKey public syntheticPoolKey;
    SyntheticHook public synthHook;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
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

    function afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24, bytes calldata data)
    external
    override
    returns (bytes4)
    {
        // TODO: Support native Eth
        require(!key.currency0.isNative());
        require(!key.currency1.isNative());

        // TODO: Add M at the beginning
        IERC20 token0 = IERC20(Currency.unwrap(key.currency0));
        IERC20 token1 = IERC20(Currency.unwrap(key.currency1));
        // TODO: Check decimals and other things
        SyntheticToken synthToken0 = new SyntheticToken(token0.name(), MAX_INT);
        SyntheticToken synthToken1 = new SyntheticToken(token1.name(), MAX_INT);

        synthToken0.approve(address(manager), MAX_INT);
        synthToken1.approve(address(manager), MAX_INT);

        synthHook = SyntheticHook(bytesToAddress(data));

        Currency synthCurrency0 = Currency.wrap(address(synthToken0));
        Currency synthCurrency1 = Currency.wrap(address(synthToken1));

        syntheticPoolKey = PoolKey(synthCurrency1, synthCurrency0, key.fee, key.tickSpacing, IHooks(synthHook));
        // TODO: Check sqrtPriceX96
        manager.initialize(syntheticPoolKey, sqrtPriceX96, ZERO_BYTES);
        return IHooks.afterInitialize.selector;
    }

    // TODO: Add owner
    function addSyntheticPoolKey(PoolKey calldata poolKey) external {
        syntheticPoolKey = poolKey;
    }

    function bytesToAddress(bytes calldata data) private pure returns (address addr) {
        bytes memory b = data;
        assembly {
            addr := mload(add(b, 20))
        }
    }

    function refillVirtualLiquidityBeforeSwap(
        PoolKey memory key,
        int24 syntheticTickBeforeSwap,
        int24 syntheticTickAfterSwap,
        int256 liquidityDelta
    ) public {
        IPoolManager.ModifyLiquidityParams memory addLiquidityParams;
        // TODO: Check order of the swap
        // TODO: Test boundary cases
        addLiquidityParams.tickUpper = syntheticTickBeforeSwap % 60 == 0 ? syntheticTickBeforeSwap : ((syntheticTickBeforeSwap / 60) - 1) * -60;
        addLiquidityParams.tickLower = syntheticTickAfterSwap % 60 == 0 ? syntheticTickAfterSwap : ((syntheticTickAfterSwap / 60) - 1) * 60;
        addLiquidityParams.liquidityDelta = liquidityDelta;
        Lock.unlock();
        console2.log(addLiquidityParams.tickLower);
        console2.log(addLiquidityParams.tickLower);
        console2.log(syntheticTickBeforeSwap);
        console2.log(syntheticTickAfterSwap / 2);
        (BalanceDelta result,) = manager.modifyLiquidity(
            key,
            addLiquidityParams,
            new bytes(0)
        );
        Lock.lock();
        key.currency0.settle(manager, address(this), uint128(-result.amount0()), false);
        key.currency1.settle(manager, address(this), uint128(-result.amount1()), false);
    }

    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata data)
    external
    override
    returns (bytes4, BeforeSwapDelta, uint24)
    {
        // TODO: Swap tokens in synthetic pool
        (uint160 synthSqrtPriceX96BeforeSwap,int24 syntheticTickBeforeSwap,,) = manager.getSlot0(syntheticPoolKey.toId());
        BalanceDelta synthSwapDelta = manager.swap(syntheticPoolKey, params, data);
        (uint160 synthSqrtPriceX96AfterSwap,int24 syntheticTickAfterSwap,,) = manager.getSlot0(syntheticPoolKey.toId());
        syntheticPoolKey.currency0.settle(manager, address(this), uint128(-synthSwapDelta.amount0()), false);
        manager.take(syntheticPoolKey.currency1, address(this), uint128(synthSwapDelta.amount1()));

        uint256 liquidityDelta = LiquidityAmounts.getLiquidityForAmount1(
            synthSqrtPriceX96BeforeSwap,
            synthSqrtPriceX96AfterSwap,
            uint128(synthSwapDelta.amount1())
        );

        // TODO: OneToZero Swap
        refillVirtualLiquidityBeforeSwap(key, syntheticTickBeforeSwap, syntheticTickAfterSwap, int(liquidityDelta));

        // data of synthetic swap

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



        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata data
    ) external override returns (bytes4, BalanceDelta) {
        console2.log("Baaaa");
        if(Lock.isUnlocked()) {
            console2.log("Here");
            return (BaseHook.afterAddLiquidity.selector, BalanceDeltaLibrary.ZERO_DELTA);
        }

        // We create the assets in the Synthetic Pool and send the results
        IPoolManager.ModifyLiquidityParams memory synthParams;
        synthParams.salt = params.salt;
        synthParams.tickLower = params.tickLower;
        synthParams.tickUpper = params.tickUpper;
        synthParams.liquidityDelta = params.liquidityDelta * 2;
        (BalanceDelta result,) = manager.modifyLiquidity(
            syntheticPoolKey,
            synthParams,
            new bytes(0)
        );
        syntheticPoolKey.currency0.settle(manager, address(this), uint128(-result.amount0()), false);
        syntheticPoolKey.currency1.settle(manager, address(this), uint128(-result.amount1()), false);

        // We take the currency
        manager.take(key.currency0, address(this), uint128(-delta.amount0()));
        manager.take(key.currency1, address(this), uint128(-delta.amount1()));
        return (BaseHook.afterAddLiquidity.selector, toBalanceDelta(-delta.amount0(), -delta.amount1()));
    }

    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata data
    ) external override returns (bytes4, BalanceDelta) {
        IPoolManager.ModifyLiquidityParams memory synthParams;
        synthParams.salt = params.salt;
        synthParams.tickLower = params.tickLower;
        synthParams.tickUpper = params.tickUpper;
        synthParams.liquidityDelta = params.liquidityDelta * 2;
        (BalanceDelta result,) = manager.modifyLiquidity(
            syntheticPoolKey,
            synthParams,
            new bytes(0)
        );

        manager.take(syntheticPoolKey.currency0, address(this), uint128(result.amount0()));
        manager.take(syntheticPoolKey.currency1, address(this), uint128(result.amount1()));

        key.currency0.settle(manager, address(this), uint128(delta.amount0()), false);
        key.currency1.settle(manager, address(this), uint128(delta.amount0()), false);

        // TODO: fee (calculated from synthetic)
        return (BaseHook.afterRemoveLiquidity.selector, toBalanceDelta(-delta.amount0(), -delta.amount1()));
    }
}
