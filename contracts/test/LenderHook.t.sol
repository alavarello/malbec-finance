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
import {Lender} from "../src/Lender/Lender.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";


contract CounterTest is Test, Deployers {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    LendingHook hook;
    SyntheticHook synthHook;
    Lender lender;

    PoolKey controlKey;

    function deploySyntheticHook() public {
        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG
                | Hooks.BEFORE_ADD_LIQUIDITY_FLAG
                | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            ) ^ (0x4444 << 145) // Namespace the hook to avoid collisions
        );
        deployCodeTo("SyntheticHook.sol:SyntheticHook", abi.encode(manager), flags);
        synthHook = SyntheticHook(flags);
    }

    function deployAndInitializeLendingPool() internal {
        deploySyntheticHook();
        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
                Hooks.AFTER_INITIALIZE_FLAG
                | Hooks.BEFORE_SWAP_FLAG
                | Hooks.AFTER_ADD_LIQUIDITY_FLAG
                | Hooks.AFTER_ADD_LIQUIDITY_RETURNS_DELTA_FLAG
                | Hooks.AFTER_REMOVE_LIQUIDITY_FLAG
                | Hooks.AFTER_REMOVE_LIQUIDITY_RETURNS_DELTA_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        deployCodeTo("LendingHook.sol:LendingHook", abi.encode(manager), flags);
        hook = LendingHook(flags);
        // Initialize a bytes array with length 20
        key = PoolKey(currency0, currency1, 0, 60, IHooks(hook));
        manager.initialize(key, SQRT_PRICE_1_1, abi.encodePacked(address(synthHook)));
    }

    function deployAndInitializeControlPool() internal {
        controlKey = PoolKey(currency0, currency1, 0, 60, IHooks(address(0x0)));
        manager.initialize(controlKey, SQRT_PRICE_1_1, ZERO_BYTES);
    }

    function setUp() public {
        // creates the pool manager, utility routers, and test tokens
        Deployers.deployFreshManagerAndRouters();
        Deployers.deployMintAndApprove2Currencies();

        deployAndInitializeLendingPool();
        deployAndInitializeControlPool();

        modifyLiquidityRouter.modifyLiquidity(
            controlKey,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 2 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 1 ether, 0),
            ZERO_BYTES
        );
    }

    function testLending() public {
        Lender lender = new Lender(key, address(manager));
        console2.log(address(lender));
        lender.setHookAddress(address(hook));
        lender.borrow(
            Currency.unwrap(currency0),
            10,
            Currency.unwrap(currency1),
            100,
            4000
        );
    }

    function testAfterInitialize() public {
        assertEq(address(hook.synthHook()), address(0x8888000000000000000000000000000000000a80));
        assertEq(address(hook), address(0x4444000000000000000000000000000000001583));
    }

    function testAddLiquidity() public {
        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 3 ether);
        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 1 ether);
        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(manager)), 3 ether);
        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(hook)), 1 ether);

        (Currency synthCurrency0, Currency synthCurrency1,,,) = hook.syntheticPoolKey();
        assertEq(IERC20(Currency.unwrap(synthCurrency0)).balanceOf(address(manager)), 2 ether);
        assertEq(IERC20(Currency.unwrap(synthCurrency1)).balanceOf(address(manager)), 2 ether);

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 0.5 ether, 0),
            ZERO_BYTES
        );

        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 3.5 ether);
        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(hook)), 1.5 ether);
        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(manager)), 3.5 ether);
        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 1.5 ether);

        assertEq(IERC20(Currency.unwrap(synthCurrency0)).balanceOf(address(manager)), 3 ether);
        assertEq(IERC20(Currency.unwrap(synthCurrency1)).balanceOf(address(manager)), 3 ether);

    }

    function testSwapZeroForOneHooks() public {
        // Perform a test swap //
        bool zeroForOne = true;
        int256 amountSpecified = 0.000000001 ether; // negative number indicates exact input swap!

        BalanceDelta controlSwapDelta = swap(controlKey, zeroForOne, amountSpecified, ZERO_BYTES);
        BalanceDelta swapDelta = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);
        BalanceDelta swapDelta1 = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);

        assertEq(int256(swapDelta.amount0()), int256(controlSwapDelta.amount0()));
        assertEq(int256(swapDelta.amount1()), int256(controlSwapDelta.amount1()));
    }

    function testSwapOneForZeroHooks() public {
        // Perform a test swap //
        bool zeroForOne = false;
        int256 amountSpecified = 0.000000001 ether; // negative number indicates exact input swap!

        BalanceDelta controlSwapDelta = swap(controlKey, zeroForOne, amountSpecified, ZERO_BYTES);

        BalanceDelta swapDelta = swap(key, zeroForOne, amountSpecified, ZERO_BYTES);

        assertEq(int256(swapDelta.amount0()), int256(controlSwapDelta.amount0()));
        assertEq(int256(swapDelta.amount1()), int256(controlSwapDelta.amount1()));
    }

    function testRemoveLiquidityHooks() public {
        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 3 ether);
        assertEq(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 1 ether);
        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(manager)), 3 ether);
        assertEq(IERC20(Currency.unwrap(currency1)).balanceOf(address(hook)), 1 ether);

        (Currency synthCurrency0, Currency synthCurrency1,,,) = hook.syntheticPoolKey();
        assertEq(IERC20(Currency.unwrap(synthCurrency0)).balanceOf(address(manager)), 2 ether);
        assertEq(IERC20(Currency.unwrap(synthCurrency1)).balanceOf(address(manager)), 2 ether);

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), -0.5 ether, 0),
            ZERO_BYTES
        );

        assertApproxEqRel(IERC20(Currency.unwrap(currency0)).balanceOf(address(manager)), 2.5 ether, 3);
        assertApproxEqRel(IERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 0.5 ether, 3);
        assertApproxEqRel(IERC20(Currency.unwrap(currency1)).balanceOf(address(manager)), 2.5 ether, 3);
        assertApproxEqRel(IERC20(Currency.unwrap(currency1)).balanceOf(address(hook)), 0.5 ether, 3);

        assertApproxEqRel(IERC20(Currency.unwrap(synthCurrency0)).balanceOf(address(manager)), 1 ether, 3);
        assertApproxEqRel(IERC20(Currency.unwrap(synthCurrency1)).balanceOf(address(manager)), 1 ether, 3);
    }
}
