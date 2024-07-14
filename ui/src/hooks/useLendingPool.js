import { useEffect, useState } from 'react'
import { LENDING_POOLS } from '../constants/lendingPools'

async function fetchTicks(poolAddress, chain = 'ETHEREUM', skip = 0, first = 1000) {
  const query = {
    operationName: 'AllV3Ticks',
    variables: { address: poolAddress, chain, skip, first },
    query: `
      query AllV3Ticks($chain: Chain!, $address: String!, $skip: Int, $first: Int) {
        v3Pool(chain: $chain, address: $address) {
          ticks(skip: $skip, first: $first) {
            tick: tickIdx
            liquidityNet
            price0
            price1
            __typename
          }
          __typename
        }
      }
    `,
  }

  const response = await fetch('https://interface.gateway.uniswap.org/v1/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(query),
  });

  const data = await response.json();
  return data.data.v3Pool.ticks;
}

async function fetchData(chainId, currency0, currency1) {
  const foundPool = LENDING_POOLS.find((pool) =>
    pool.chainId === chainId && (
      (pool.currency0 === currency0 && pool.currency1 === currency1) ||
      (pool.currency1 === currency0 && pool.currency0 === currency0)
    )
  )

  if (foundPool) {
    const ticks = await fetchTicks(foundPool.address)
    const currentTick = ticks.find((tick) => tick.tick === 0)
    const price0 = parseFloat(currentTick.price0)
    const price1 = parseFloat(currentTick.price1)

    return { ...foundPool, ticks, price0, price1 }
  }

  throw new Error(
    `Pool between ${currency0} and ${currency1} for ${chainId} not found`
  )
}

export default function useLendingPool({ chainId, currency0, currency1 }) {
  const [pool, setPool] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    setLoading(true)
    fetchData(chainId, currency0, currency1).then((pool) => {
      setPool(pool)
    }).catch((err) => {
      setError(err)
    }).finally(() => {
      setLoading(false)
    })
  }, [chainId, currency0, currency1]);

  return { pool, loading, error }
}
