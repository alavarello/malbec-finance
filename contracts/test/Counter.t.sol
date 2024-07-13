// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {LendingHook} from "../src/LendingHook.sol";
import {SyntheticHook} from "../src/SyntheticHook.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";


contract CounterTest is Test, Deployers {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    LendingHook hook;
    SyntheticHook synthHook;

    PoolId poolId;
    PoolKey controlKey;
    PoolKey synthKey;

    function deployAndInitializeSyntheticPool() internal {
        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG
                | Hooks.BEFORE_ADD_LIQUIDITY_FLAG
                | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        synthHook = SyntheticHook(flags);
        synthKey = PoolKey(currency0, currency1, 3000, 60, IHooks(synthHook));
        manager.initialize(synthKey, SQRT_PRICE_1_1, ZERO_BYTES);
    }

    function deployAndInitializeLendingPool() internal {
        deployAndInitializeSyntheticPool();
        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
//                Hooks.BEFORE_INITIALIZE_FLAG
//                    | Hooks.BEFORE_SWAP_FLAG
                Hooks.BEFORE_SWAP_FLAG
                | Hooks.AFTER_ADD_LIQUIDITY_FLAG
                | Hooks.AFTER_ADD_LIQUIDITY_RETURNS_DELTA_FLAG
                | Hooks.AFTER_REMOVE_LIQUIDITY_FLAG
                | Hooks.AFTER_REMOVE_LIQUIDITY_RETURNS_DELTA_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        hook = LendingHook(flags);
        controlKey = PoolKey(currency0, currency1, 3000, 60, IHooks(address(0x0)));
        manager.initialize(controlKey, SQRT_PRICE_1_1, ZERO_BYTES);
//        hook.addSyntheticPoolKey(synthKey);
    }

    function deployAndInitializeControlPool() internal {
        key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = key.toId();
        manager.initialize(key, SQRT_PRICE_1_1, ZERO_BYTES);
    }

    function setUp() public {
        // creates the pool manager, utility routers, and test tokens
        Deployers.deployFreshManagerAndRouters();
        Deployers.deployMintAndApprove2Currencies();

        deployAndInitializeLendingPool();
        deployAndInitializeControlPool();
    }

//    function testInitialize() public {
//        assertEq(hook.syntheticPoolId(), controlKey.toId());
//    }

    function testSwaprHooks() public {
        modifyLiquidityRouter.modifyLiquidity(
            controlKey,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 6 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(-600, 600, 6 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(-180, 120, 2 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(60, 120, 2 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(60, 180, 6 ether, 0),
            ZERO_BYTES
        );

//
//        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 9 ether);


        // Perform a test swap //
        bool zeroForOne = true;
        int256 amountSpecified = 0.01 ether; // negative number indicates exact input swap!
//
////        vm.prank(controlUser);
//        BalanceDelta controlSwapDelta = swap(controlKey, zeroForOne, amountSpecified, ZERO_BYTES);
        BalanceDelta swapDelta = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
        BalanceDelta swapDelta1 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta2 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta3 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta4 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta5 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta6 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta7 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta8 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
//        BalanceDelta swapDelta9 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
        // ------------------- //

        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 3 ether);

//        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 1.5 ether);
//        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 10 ether);

//        assertEq(int256(swapDelta.amount0()), int256(controlSwapDelta.amount0()));
//        assertEq(int256(swapDelta.amount1()), int256(controlSwapDelta.amount1()));

    }

//    function testAddLiquidityHooks() public {
////        // positions were created in setup()
//        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 1 ether);
//        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(hook)), 1 ether);
//    }

//    function testRemoveLiquidityHooks() public {
//        modifyLiquidityRouter.modifyLiquidity(
//            controlKey,
//            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), -1 ether, 0),
//            ZERO_BYTES
//        );
//        modifyLiquidityRouter.modifyLiquidity(
//            key,
//            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), -1 ether, 0),
//            ZERO_BYTES
//        );
//    }
}
