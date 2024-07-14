import { LENDING_CONDITIONS } from '../constants/lending'

export function calculateAvailableTokens(pool, targetPrice, lendingCondition, token) {
  return pool.ticks.reduce((availableTokens, tick) => {
    const price = parseFloat(token === pool.currency0 ? tick.price0 : tick.price1);
    if (
      lendingCondition === LENDING_CONDITIONS.Short && targetPrice <= price ||
      lendingCondition === LENDING_CONDITIONS.Long && targetPrice >= price
    ) {
      return availableTokens + parseFloat(tick.liquidityNet)
    }
    return availableTokens
  })
}
