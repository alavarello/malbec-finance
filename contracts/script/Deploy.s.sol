// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {LendingHook} from "../src/LendingHook.sol";
import {SyntheticHook} from "../src/SyntheticHook.sol";
import {SyntheticToken} from "../src/SyntheticToken.sol";
import {Lender} from "../src/Lender/Lender.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {LPFeeLibrary} from "v4-core/src/libraries/LPFeeLibrary.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {PoolModifyLiquidityTest} from "v4-core/src/test/PoolModifyLiquidityTest.sol";
import {PoolModifyLiquidityTestNoChecks} from "v4-core/src/test/PoolModifyLiquidityTestNoChecks.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {SwapRouterNoChecks} from "v4-core/src/test/SwapRouterNoChecks.sol";
import {PoolDonateTest} from "v4-core/src/test/PoolDonateTest.sol";
import {PoolNestedActionsTest} from "v4-core/src/test/PoolNestedActionsTest.sol";
import {PoolTakeTest} from "v4-core/src/test/PoolTakeTest.sol";
import {PoolSettleTest} from "v4-core/src/test/PoolSettleTest.sol";
import {PoolClaimsTest} from "v4-core/src/test/PoolClaimsTest.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";
import {SortTokens} from "v4-core/test/utils/SortTokens.sol";
import {
ProtocolFeeControllerTest,
OutOfBoundsProtocolFeeControllerTest,
RevertingProtocolFeeControllerTest,
OverflowProtocolFeeControllerTest,
InvalidReturnSizeProtocolFeeControllerTest
} from "v4-core/src/test/ProtocolFeeControllerTest.sol";

contract DeployScript is Script {
    LendingHook hook;
    SyntheticHook synthHook;
    Lender lender;

    PoolKey controlKey;

    Currency internal currency0;
    Currency internal currency1;
    PoolManager manager;
    PoolModifyLiquidityTest modifyLiquidityRouter;
    PoolModifyLiquidityTestNoChecks modifyLiquidityNoChecks;
    SwapRouterNoChecks swapRouterNoChecks;
    PoolSwapTest swapRouter;
    PoolDonateTest donateRouter;
    PoolTakeTest takeRouter;
    PoolSettleTest settleRouter;

    PoolClaimsTest claimsRouter;
    PoolNestedActionsTest nestedActionRouter;
    ProtocolFeeControllerTest feeController;
    RevertingProtocolFeeControllerTest revertingFeeController;
    OutOfBoundsProtocolFeeControllerTest outOfBoundsFeeController;
    OverflowProtocolFeeControllerTest overflowFeeController;
    InvalidReturnSizeProtocolFeeControllerTest invalidReturnSizeFeeController;

    PoolKey key;
    PoolKey nativeKey;
    PoolKey uninitializedKey;
    PoolKey uninitializedNativeKey;

    // Update this value when you add a new hook flag.
    uint160 hookPermissionCount = 14;
    uint160 clearAllHookPermissionsMask = ~uint160(0) << (hookPermissionCount);

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

    function deployCodeTo(string memory what, bytes memory args, address where) internal virtual {
        bytes memory creationCode = vm.getCode(what);
        vm.etch(where, abi.encodePacked(creationCode, args));
        (bool success, bytes memory runtimeBytecode) = where.call{value: 0}("");
        require(success, "StdCheats deployCodeTo(string,bytes,uint256,address): Failed to create runtime bytecode.");
        vm.etch(where, runtimeBytecode);
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
        key = PoolKey(currency0, currency1, 0, 60, IHooks(hook));
//        manager.initialize(key, Constants.SQRT_PRICE_1_1, abi.encodePacked(address(synthHook)));
    }

    function deployAndInitializeControlPool() internal {
        controlKey = PoolKey(currency0, currency1, 0, 60, IHooks(address(0x0)));
//        manager.initialize(controlKey, Constants.SQRT_PRICE_1_1, Constants.ZERO_BYTES);
    }

    function deployFreshManager() internal virtual {
        manager = new PoolManager(500000);
    }

    function deployFreshManagerAndRouters() internal {
        deployFreshManager();
        swapRouter = new PoolSwapTest(manager);
        swapRouterNoChecks = new SwapRouterNoChecks(manager);
        modifyLiquidityRouter = new PoolModifyLiquidityTest(manager);
        modifyLiquidityNoChecks = new PoolModifyLiquidityTestNoChecks(manager);
        donateRouter = new PoolDonateTest(manager);
        takeRouter = new PoolTakeTest(manager);
        settleRouter = new PoolSettleTest(manager);
        claimsRouter = new PoolClaimsTest(manager);
        nestedActionRouter = new PoolNestedActionsTest(manager);
        feeController = new ProtocolFeeControllerTest();
        revertingFeeController = new RevertingProtocolFeeControllerTest();
        outOfBoundsFeeController = new OutOfBoundsProtocolFeeControllerTest();
        overflowFeeController = new OverflowProtocolFeeControllerTest();
        invalidReturnSizeFeeController = new InvalidReturnSizeProtocolFeeControllerTest();

        manager.setProtocolFeeController(feeController);
    }

    // You must have first initialised the routers with deployFreshManagerAndRouters
    // If you only need the currencies (and not approvals) call deployAndMint2Currencies
    function deployMintAndApprove2Currencies() internal returns (Currency, Currency) {
        Currency _currencyA = deployMintAndApproveCurrency();
        Currency _currencyB = deployMintAndApproveCurrency();

        (currency0, currency1) =
        SortTokens.sort(MockERC20(Currency.unwrap(_currencyA)), MockERC20(Currency.unwrap(_currencyB)));
        return (currency0, currency1);
    }


    function deployMintAndApproveCurrency() internal returns (Currency currency) {
        MockERC20 token = deployTokens(1, 2 ** 255)[0];

        address[8] memory toApprove = [
                        address(swapRouter),
                        address(swapRouterNoChecks),
                        address(modifyLiquidityRouter),
                        address(modifyLiquidityNoChecks),
                        address(donateRouter),
                        address(takeRouter),
                        address(claimsRouter),
                        address(nestedActionRouter.executor())
            ];

        for (uint256 i = 0; i < toApprove.length; i++) {
            token.approve(toApprove[i], Constants.MAX_UINT256);
        }

        return Currency.wrap(address(token));
    }

    function deployTokens(uint8 count, uint256 totalSupply) internal returns (MockERC20[] memory tokens) {
        tokens = new MockERC20[](count);
        for (uint8 i = 0; i < count; i++) {
            tokens[i] = new MockERC20("TEST", "TEST", 18);
            tokens[i].mint(address(this), totalSupply);
        }
    }

    function run() external {
        vm.startBroadcast();
        address deployer = msg.sender;
        deployFreshManagerAndRouters();
        deployMintAndApprove2Currencies();

        deployAndInitializeLendingPool();
        deployAndInitializeControlPool();

//        console2.log(deployer);
//        console2.log(manager.owner());

//        modifyLiquidityRouter.modifyLiquidity(
//            controlKey,
//            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 200 ether, 0),
//            Constants.ZERO_BYTES
//        );
//
//        modifyLiquidityRouter.modifyLiquidity(
//            key,
//            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 5 ether, 0),
//            Constants.ZERO_BYTES
//        );

        Lender lender = new Lender(key, address(manager));
        console2.log(address(lender));
        lender.setHookAddress(address(hook));
        vm.stopBroadcast();
    }

}
