import Position from './Position'
import { useWallet } from '../stores/wallet'
import usePositions from '../hooks/usePositions'
import '../styles/positions.css'
import ErrorButton from './ErrorButton'

export default function PositionList() {
  const { chainId, address, isConnected } = useWallet()
  const {
    positions,
    loading: positionsLoading,
    error: positionsError,
  } = usePositions({ chainId, address })

  if (!isConnected) {
    return null
  }

  return (
    <div className="position-list">
      <h3>Your Positions</h3>
      {positions && !positionsLoading && !positionsError && (
        <ul className="positions">
          <li>
            {positions.map((position) => (
              <Position
                key={`${position.pool.poolId}-${position.debt.currency}`}
                borrower={address}
                pool={position.pool}
                colateral={{
                  chainId,
                  currency: position.colateral.currency,
                  value: position.colateral.value,
                  liquidation: position.colateral.liquidation,
                }}
                debt={{
                  chainId,
                  currency: position.debt.currency,
                  value: position.debt.value,
                  liquidation: position.debt.liquidation,
                }}
                interest={position.interest}
              />
            ))}
          </li>
        </ul>
      )}
      {positionsLoading && !positionsError && <Spinner />}
      {positionsError && !positionsLoading && (
        <ErrorButton message={positionsError} />
      )}
    </div>
  )
}
