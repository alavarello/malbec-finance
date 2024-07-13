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
import {Counter} from "../src/Counter.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";


contract CounterTest is Test, Deployers {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    Counter hook;
    PoolId poolId;
    PoolKey controlKey;

    function setUp() public {
        // creates the pool manager, utility routers, and test tokens
        Deployers.deployFreshManagerAndRouters();
        Deployers.deployMintAndApprove2Currencies();

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG
                    | Hooks.AFTER_ADD_LIQUIDITY_FLAG
                    | Hooks.AFTER_ADD_LIQUIDITY_RETURNS_DELTA_FLAG
                    | Hooks.AFTER_REMOVE_LIQUIDITY_FLAG
                    | Hooks.AFTER_REMOVE_LIQUIDITY_RETURNS_DELTA_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        deployCodeTo("Counter.sol:Counter", abi.encode(manager), flags);
        hook = Counter(flags);

        controlKey = PoolKey(currency0, currency1, 3000, 60, IHooks(address(0x0)));
        manager.initialize(controlKey, SQRT_PRICE_1_1, ZERO_BYTES);
        // Create the pool
        key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = key.toId();
        manager.initialize(key, SQRT_PRICE_1_1, ZERO_BYTES);
    }

    function testSwaprHooks() public {
        modifyLiquidityRouter.modifyLiquidity(
            controlKey,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 3 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 3 ether, 0),
            ZERO_BYTES
        );

        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 3 ether);
        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 6 ether);


        // Perform a test swap //
        bool zeroForOne = true;
        int256 amountSpecified = -1e18; // negative number indicates exact input swap!

//        vm.prank(controlUser);
        BalanceDelta controlSwapDelta = swap(controlKey, zeroForOne, amountSpecified, ZERO_BYTES);
        BalanceDelta swapDelta = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
        // ------------------- //

        assertEq(int256(swapDelta.amount0()), int256(controlSwapDelta.amount0()));
        assertEq(int256(swapDelta.amount1()), int256(controlSwapDelta.amount1()));

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
