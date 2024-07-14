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
import {PoolGetters} from "v4-periphery/libraries/PoolGetters.sol";
import {LiquidityAmounts} from "v4-periphery/libraries/LiquidityAmounts.sol";
import {SyntheticHook} from "./SyntheticHook.sol";
import {SyntheticToken} from "./SyntheticToken.sol";
import {Lock} from "v4-core/src/libraries/Lock.sol";
import {BitMath} from "v4-core/src/libraries/TickBitmap.sol";


contract LendingHook is BaseHook {
    bytes constant ZERO_BYTES = new bytes(0);
    uint256 MAX_INT = type(uint256).max;

    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;
    using StateLibrary for IPoolManager;
    using PoolGetters for IPoolManager;

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

    function bytesToAddress(bytes calldata data) private pure returns (address addr) {
        bytes memory b = data;
        assembly {
            addr := mload(add(b, 20))
        }
    }
    
    function getIntervalWithMultipleOfTickSpace(int24 a, int24 b, int24 tickSpacing) public pure returns (int24, int24) {
        // Ensure a is the smaller number and b is the larger number
        int24 minVal = a < b ? a : b;
        int24 maxVal = a > b ? a : b;

        // Find the lower bound multiple of tickSpacing
        int24 lowerBound;
        if (minVal >= 0) {
            lowerBound = (minVal / tickSpacing) * tickSpacing;
        } else {
            lowerBound = ((minVal + 1) / tickSpacing - 1) * tickSpacing;
        }

        // Find the upper bound multiple of tickSpacing
        int24 upperBound;
        if (maxVal % tickSpacing == 0) {
            upperBound = maxVal;
        } else if (maxVal >= 0) {
            upperBound = ((maxVal / tickSpacing) + 1) * tickSpacing;
        } else {
            upperBound = ((maxVal - 1) / tickSpacing + 1) * tickSpacing;
        }

        return (lowerBound, upperBound);
    }

    function refillVirtualLiquidityBeforeSwapZeroForOne(
        PoolKey memory key,
        int24 syntheticTickBeforeSwap,
        int24 syntheticTickAfterSwap,
        int256 liquidityDelta
    ) public {
        IPoolManager.ModifyLiquidityParams memory addLiquidityParams;
        // TODO: Check order of the swap
        // TODO: Test boundary cases

        if(syntheticTickBeforeSwap == 0 && syntheticTickAfterSwap ==0) {
            addLiquidityParams.tickLower = -key.tickSpacing;
            addLiquidityParams.tickUpper = 0;
        } else {
            (int24 lowerBound, int24 upperBound) = getIntervalWithMultipleOfTickSpace(
                syntheticTickBeforeSwap,
                syntheticTickAfterSwap,
                key.tickSpacing
            );
            addLiquidityParams.tickLower = lowerBound;
            addLiquidityParams.tickUpper = upperBound;
        }

        addLiquidityParams.liquidityDelta = liquidityDelta;

        Lock.unlock();
        (BalanceDelta result,) = manager.modifyLiquidity(
            key,
            addLiquidityParams,
            new bytes(0)
        );
        Lock.lock();
        key.currency0.settle(manager, address(this), uint128(-result.amount0()), false);
        key.currency1.settle(manager, address(this), uint128(-result.amount1()), false);
    }

    function refillVirtualLiquidityBeforeSwapOneForZero(
        PoolKey memory key,
        int24 syntheticTickBeforeSwap,
        int24 syntheticTickAfterSwap,
        int256 liquidityDelta
    ) public {
        IPoolManager.ModifyLiquidityParams memory addLiquidityParams;
        // TODO: Check order of the swap
        // TODO: Test boundary cases

       if(syntheticTickBeforeSwap == 0 && syntheticTickAfterSwap ==0) {
            addLiquidityParams.tickLower = 0;
            addLiquidityParams.tickUpper = key.tickSpacing;
        } else {
            (int24 lowerBound, int24 upperBound) = getIntervalWithMultipleOfTickSpace(
                syntheticTickBeforeSwap,
                syntheticTickAfterSwap,
                key.tickSpacing
            );
            addLiquidityParams.tickLower = lowerBound;
            addLiquidityParams.tickUpper = upperBound;
        }

        addLiquidityParams.liquidityDelta = liquidityDelta;

        Lock.unlock();
        (BalanceDelta result,) = manager.modifyLiquidity(
            key,
            addLiquidityParams,
            new bytes(0)
        );
        Lock.lock();
        key.currency0.settle(manager, address(this), uint128(-result.amount0()), false);
        key.currency1.settle(manager, address(this), uint128(-result.amount1()), false);
    }

    function settleSyntheticSwap(BalanceDelta synthSwapDelta, bool zeroForOne) public {
        if (zeroForOne) {
            syntheticPoolKey.currency0.settle(manager, address(this), uint128(-synthSwapDelta.amount0()), false);
            manager.take(syntheticPoolKey.currency1, address(this), uint128(synthSwapDelta.amount1()));
        } else {
            syntheticPoolKey.currency1.settle(manager, address(this), uint128(-synthSwapDelta.amount1()), false);
            manager.take(syntheticPoolKey.currency0, address(this), uint128(synthSwapDelta.amount0()));
        }
    }

    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata data)
    external
    override
    returns (bytes4, BeforeSwapDelta, uint24)
    {
        (uint160 synthSqrtPriceX96BeforeSwap, int24 syntheticTickBeforeSwap ,,) = 
            manager.getSlot0(syntheticPoolKey.toId());
        
        BalanceDelta synthSwapDelta = manager.swap(syntheticPoolKey, params, data);

        (uint160 synthSqrtPriceX96AfterSwap, int24 syntheticTickAfterSwap ,,) = 
            manager.getSlot0(syntheticPoolKey.toId());

        settleSyntheticSwap(synthSwapDelta, params.zeroForOne);
            
        uint256 liquidityDelta = LiquidityAmounts.getLiquidityForAmount1(
            synthSqrtPriceX96BeforeSwap,
            synthSqrtPriceX96AfterSwap,
            uint128(params.zeroForOne ? synthSwapDelta.amount1() : synthSwapDelta.amount0())
        );

        params.zeroForOne ? 
            refillVirtualLiquidityBeforeSwapZeroForOne(
                key, syntheticTickBeforeSwap, syntheticTickAfterSwap, int(liquidityDelta)
            ) : 
            refillVirtualLiquidityBeforeSwapOneForZero(
                key, syntheticTickBeforeSwap, syntheticTickAfterSwap, int(liquidityDelta)
            );

        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata data
    ) external override returns (bytes4, BalanceDelta) {
        if(Lock.isUnlocked()) {
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
