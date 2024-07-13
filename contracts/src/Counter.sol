// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/BaseHook.sol";
import "forge-std/Test.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta, toBalanceDelta, BalanceDeltaLibrary} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {CurrencySettler} from "v4-core/test/utils/CurrencySettler.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------

    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    mapping(PoolId => uint256 count) public beforeAddLiquidityCount;
    mapping(PoolId => uint256 count) public beforeRemoveLiquidityCount;

    bool public lock = false;

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

        IERC20(Currency.unwrap(key.currency0)).approve(address(manager), 5 ether);
        IERC20(Currency.unwrap(key.currency1)).approve(address(manager), 5 ether);

        (BalanceDelta result,) = manager.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 6 ether, 0),
            new bytes(0)
        );
        console2.log(result.amount0());
        console2.log(result.amount1());
        key.currency0.settle(manager, address(this), uint128(-result.amount0()), false);
        key.currency1.settle(manager, address(this), uint128(-result.amount1()), false);

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
