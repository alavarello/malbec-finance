import { useEffect, useState } from 'react'
import { PYTH, PRICE_FEED_IDS } from '../lib/pyth'

export default function useCoinPrice({ chainId, currency }) {
  const [price, setPrice] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!PYTH[chainId]) {
      setError(new Error(
        `Price for ${currency} on ${chainId} not available: contract not found`
      ))
    } else if (!PRICE_FEED_IDS[currency]) {
      setError(new Error(
        `Price for ${currency} on ${chainId} not available: price feed id not found`
      ))
    } else {
      setLoading(true)
      PYTH[chainId].getPrice(PRICE_FEED_IDS[currency]).then(([price]) => {
        setPrice(price)
      }).catch((err) => {
        setError(new Error(
          `Fetch price for ${currency} on ${chainId} failed: ${err}`
        ))
      }).finally(() => {
        setLoading(false)
      })
    }
  }, [])

  return {
    price,
    loading,
    error,
  }
}
