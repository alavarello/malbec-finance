import { LENDING_CONDITIONS } from '../constants/lending'

export function calculateAvailableTokens(pool, targetPrice, positionType, token) {
  let availableTokens = 0;

  pool.ticks.forEach(tick => {
    const price = parseFloat(token === pool.currency0 ? tick.price0 : tick.price1);

    if (
      positionType === LENDING_CONDITIONS.Short && targetPrice <= price
      || positionType === LENDING_CONDITIONS.Long && targetPrice >= price
    ) {
      availableTokens += parseFloat(tick.liquidityNet);
    }
  });

  return availableTokens;
}
