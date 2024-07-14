// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";

contract Lender {
    using StateLibrary for IPoolManager;
    using PoolIdLibrary for PoolKey;

    struct DebtPosition {
        address collateralToken;
        uint256 amountOfCollateral;
        address debtToken;
        uint256 amountOfDebt;
        uint256 poolLiquidationPrice;
        bool rightLiquidity;
    }

    mapping(uint256 positionId => DebtPosition position) public positions;
    PoolKey key;
    address hookAddress;
    IPoolManager manager;
    uint256 nextPositionId = 1;

    constructor(PoolKey memory initKey, address managerAddress) {
        key = initKey;
        manager = IPoolManager(managerAddress);
    }

    //  (ETH/USD -> 3200)
    function getPrice(address token0, address token1) internal returns(uint256) {
        return 1;
    }

    // TODO: Add Ownable
    function setHookAddress(address newHookAddress) external {
        hookAddress;
    }

    function convertSqrtPriceX96ToPrice(
        uint160 sqrtPriceX96
    ) public pure returns (uint256) {
        // Convert the sqrtPriceX96 to a regular price using Uniswap's formula.
        uint256 price = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) >> 96;
        return price;
    }

    function borrow(address collateralToken, uint256 amountOfCollateral, address debtToken, uint256 amountOfDebt, uint256 poolLiquidationPrice) external {
        DebtPosition memory newPosition;
        newPosition.collateralToken = collateralToken;
        newPosition.amountOfCollateral = amountOfCollateral;
        newPosition.debtToken = debtToken;
        newPosition.amountOfDebt = amountOfDebt;
        newPosition.poolLiquidationPrice = poolLiquidationPrice;
        // TODO: Change
        newPosition.rightLiquidity = false;

        // Check that the amountOfDebt is healthy with the price of the debt token and the amount of debtToken
        if(canLiquidateWithPoolPrice(newPosition) || canLiquidateWithCollateralPrice(newPosition)) {
            revert("Can't Borrow with these parameters");
        }

        positions[nextPositionId] = newPosition;
        nextPositionId++;

        // Check that we have the liquidity
//        (int24 nextTicker,) = manager.getNextInitializedTickWithinOneWord(key.toId(), tickCurrent, key.tickSpacing, true);

    }

    function liquidatePosition(uint256 positionId, DebtPosition memory positionToLiquidate) internal {
        // TODO: Use the Pool
        IERC20(positionToLiquidate.debtToken).transferFrom(
            msg.sender,
            hookAddress,
            positionToLiquidate.amountOfDebt
        );

        // If the transfer is successful give all the tokens to the liquidator
        IERC20(positionToLiquidate.collateralToken).transferFrom(
            hookAddress,
            msg.sender,
            positionToLiquidate.amountOfCollateral
        );

        delete positions[positionId];
    }

    function canLiquidateWithPoolPrice(DebtPosition memory positionToLiquidate) internal returns(bool) {
        (uint160 sqrtPriceX96,,,) = manager.getSlot0(key.toId());
        uint256 poolPrice = convertSqrtPriceX96ToPrice(sqrtPriceX96);
        console2.log(poolPrice);
        console2.log(positionToLiquidate.poolLiquidationPrice);
        console2.log(positionToLiquidate.rightLiquidity ? "true" : "false");
        // TODO: Add buffer
        return positionToLiquidate.rightLiquidity ?
            positionToLiquidate.poolLiquidationPrice <= poolPrice :
            positionToLiquidate.poolLiquidationPrice >= poolPrice;
    }

    function liquidateWithPoolPrice(uint256 positionId) internal {
        DebtPosition memory positionToLiquidate = positions[positionId];
        if(!canLiquidateWithPoolPrice(positionToLiquidate)) {
            // TODO: Add custom errors
            revert("Can't Liquidate Position");
        }
        liquidatePosition(positionId, positionToLiquidate);
    }

    function canLiquidateWithCollateralPrice(DebtPosition memory positionToLiquidate) internal returns(bool) {
        uint256 price = getPrice(positionToLiquidate.debtToken, positionToLiquidate.collateralToken);
        // TODO: This assumes that the collateral is always the first token of the pair in the price
        // TODO: Add delta for price liquidation
        if(price * positionToLiquidate.amountOfCollateral > positionToLiquidate.amountOfDebt) {
            console2.log("true");
            return true;
        }
        console2.log("false");
        return false;
    }

    function liquidateWithCollateralPrice(uint256 positionId) internal {
        DebtPosition memory positionToLiquidate = positions[positionId];
        if(!canLiquidateWithCollateralPrice(positionToLiquidate)) {
            // TODO: Add custom errors
            revert("Can't Liquidate Position");
        }
        liquidatePosition(positionId, positionToLiquidate);
    }
}
