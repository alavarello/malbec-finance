import { LENDING_CONDITIONS } from '../constants/lending'

export function calculateAvailableTokens(pool, targetPrice, lendingCondition) {
  return pool.ticks.reduce((availableTokens, tick) => {
    if (
      lendingCondition === LENDING_CONDITIONS.Short && targetPrice <= price ||
      lendingCondition === LENDING_CONDITIONS.Long && targetPrice >= price
    ) {
      return availableTokens + parseFloat(tick.liquidityNet)
    }
    return availableTokens
  })
}
