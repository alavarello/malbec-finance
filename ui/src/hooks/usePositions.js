import { LENDING_CONDITIONS } from '../constants/lending'
import { useEffect, useState } from 'react'
import { LENDERS } from '../lib/lender'

async function fetchPositions(chainId, ownerAddress) {
  return LENDERS[chainId].positions(ownerAddress)
}

export default function usePositions({ chainId, address }) {
  const [positions, setPositions] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (!LENDERS[chainId]) {
      setError(new Error(
        `Positions on ${chainId} not available: chain not found`
      ))
    } else {
      setLoading(true)
      fetchPositions(chainId, address).then((positionsResponse) => {
        setPositions(positionsResponse)
      }).catch((err) => {
        setError(new Error(
          `Fetch positions for on ${chainId} failed: ${err}`
        ))
      }).finally(() => {
        setLoading(false)
      })
    }
  }, [chainId, address])

  return {
    positions: [
      ...positions,
      {
        pool: {
          poolId: '0x0000',
          currency0: 'DAI',
          currency1: 'USDC',
        },
        colateral: {
          currency: 'ETH',
          value: '3',
          liquidation: {
            price: '3500000000000000000000000',
            lendingCondition: LENDING_CONDITIONS.Long,
          },
        },
        debt: {
          currency: 'USDC',
          value: '10000',
          liquidation: {
            price: '100000000000000000000',
            lendingCondition: LENDING_CONDITIONS.Short,
          },
        },
        interest: {
          rate: null,
          fee: {
            currency: 'ETH',
            value: '100000000000000000',
          },
        },
      },
    ],
    loading,
    error,
  }
}
