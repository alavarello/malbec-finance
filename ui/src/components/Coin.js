import Spinner from './Spinner'
import useCoinPrice from '../hooks/useCoinPrice'
import ButtonModal from './ButtonModal'
import ErrorMessage from './ErrorMessage'

export default function Coin({ chainId, currency, amount }) {
  const {
    price,
    loading: priceLoading,
    error: priceError,
  } = useCoinPrice({ chainId, currency })

  return (
    <div className="coin">
      <div className="icon"></div>
      <div className="value">
        {price && (
          <div className="price">${price}</div>
        )}
        {priceLoading && <Spinner size={12} />}
        {priceError && (
          <ButtonModal
            className="error-button"
            modal={ErrorMessage}
            message={priceError}
          >
            ⚠️
          </ButtonModal>
        )}
        <div className="amount">{amount} {currency}</div>
      </div>
    </div>
  )
}
