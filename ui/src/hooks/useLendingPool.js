import { useEffect, useState } from 'react'
import { lendingPools } from '../constants/lendingPools'

export default function useLendingPool({ chainId, currency0, currency1 }) {
  const [pool, setPool] = useState(null);

  async function fetchTicks(poolAddress, chain = 'ETHEREUM', skip = 0, first = 1000) {
    const query = {
      operationName: "AllV3Ticks",
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
    `
    };

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

  useEffect(() => {
    async function fetchData() {
      const foundPool = lendingPools.find(pool =>
        (pool.currency0 === currency0 && pool.currency1 === currency1) ||
        (pool.currency1 === currency0 && pool.currency0 === currency0)
      );

      if (foundPool) {
        const ticks = await fetchTicks(foundPool.address);
        const currentTick = pool.ticks.find(tick => tick.tick === 0);
        const price0 = parseFloat(currentTick.price0);
        const price1 = parseFloat(currentTick.price1);

        setPool({ ...foundPool, ticks, price0, price1 });
      } else {
        setPool(null);
      }
    }

    fetchData();
  }, [currency0, currency1]);

  return pool;
}
