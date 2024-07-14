// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {LendingHook} from "../src/LendingHook.sol";
import {SyntheticHook} from "../src/SyntheticHook.sol";
import {SyntheticToken} from "../src/SyntheticToken.sol";
import {Lender} from "../src/Lender/Lender.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";

contract DeployScript is Script, Deployers, Test {
    LendingHook hook;
    SyntheticHook synthHook;
    Lender lender;

    PoolKey controlKey;

    function setUp() public {}

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

    function run() public {
        Deployers.deployFreshManagerAndRouters();
        Deployers.deployMintAndApprove2Currencies();

        deployAndInitializeLendingPool();
        deployAndInitializeControlPool();

        modifyLiquidityRouter.modifyLiquidity(
            controlKey,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 200 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 5 ether, 0),
            ZERO_BYTES
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(-600, 600, 5 ether, 0),
            ZERO_BYTES
        );

    }

}
