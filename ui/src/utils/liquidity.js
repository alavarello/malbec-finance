import { parseUnits } from 'ethers'
import { LENDING_CONDITIONS } from '../constants/lending'
import { COINS } from '../constants/coins'

export function calculateAvailableTokens(pool, targetPrice, lendingCondition, token) {
  return pool.ticks.reduce((availableTokens, tick) => {
    const currency = token === pool.currency0 ? pool.currency0 : pool.currency1
    const price = parseFloat(token === pool.currency0 ? tick.price0 : tick.price1);
    if (
      lendingCondition === LENDING_CONDITIONS.Short && targetPrice <= price ||
      lendingCondition === LENDING_CONDITIONS.Long && targetPrice >= price
    ) {
      console.debug(tick.liquidityNet)
      return availableTokens + parseUnits(tick.liquidityNet, COINS[currency]?.decimals ?? 18)
    }
    return availableTokens
  }, 0n)
}
