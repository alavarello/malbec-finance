export function getCoinPrice(pool, currency) {
  if (!pool) {
    return null
  }
  if (pool.currency0 === currency) {
    return pool.price0
  }
  if (pool.currency1 === currency) {
    return pool.price1
  }
  return null
}
