import { formatUnits } from 'ethers'
import { COINS } from '../constants/coins'

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

export function calculateMax(pool, amount, currency) {
  if (!currency || !amount || !pool) {
    return undefined
  }

  const value = BigInt(parseFloat(amount))
  const price = getCoinPrice(pool, currency)

  return formatUnits(String(value * price), COINS[currency]?.decimals)
}
