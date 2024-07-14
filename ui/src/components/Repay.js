import { useState } from 'react'
import { LENDERS } from '../lib/lender'
import { useWallet } from '../stores/wallet'
import Card from './Card'
import Coin from './Coin'
import Spinner from './Spinner'
import SuccessMessage from './SuccessMessage'

export default function Repay({ onClose, debt }) {
  const { isConnected, chainId } = useWallet()
  const [success, setSuccess] = useState(true)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const isRepayValid = (
    isConnected &&
    LENDERS[chainId]
  )

  const handleRepay = () => {
    setLoading(true)
    LENDERS[chainId].repay().then(() => {
      setSuccess(true)
    }).catch((err) => {
      setError(new Error(`Could not borrow: ${err}`))
    }).finally(() => {
      setLoading(false)
    })
  }

  return (
    <Card>
      {success && <SuccessMessage>You have repayed you debt!</SuccessMessage>}
      {!success && (
        <>
          <h2>Repay your debt</h2>
          {loading && !error && <Spinner size={96} />}
          <p>You are about to repay:</p>
          <Coin
            chainId={debt.chainId}
            currency={debt.currency}
            value={debt.value}
          />
          {error && !loading && <ErrorButton message={error} />}
          <div className="actions">
            <button disabled={!isRepayValid} onClick={() => handleRepay()}>Repay</button>
          </div>
        </>
      )}
    </Card>
  )
}
