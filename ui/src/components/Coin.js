import { parseUnits } from 'ethers'
import Spinner from './Spinner'
import ErrorButton from './ErrorButton'
import useCoinPrice from '../hooks/useCoinPrice'
import { COINS } from '../constants/coins'

export default function Coin({ chainId, currency, value }) {
  const {
    price,
    loading: priceLoading,
    error: priceError,
  } = useCoinPrice({
    chainId,
    currency,
  })

  const decimals = COINS[currency]?.decimals ?? 18
  const amount = parseUnits(value, decimals)

  return (
    <div className="coin">
      <div className="icon"></div>
      <div className="value">
        {price && (
          <div className="price">${amount * price}</div>
        )}
        {priceLoading && <Spinner size={12} />}
        {priceError && <ErrorButton message={priceError} />}
        <div className="amount">{amount} {currency}</div>
      </div>
    </div>
  )
}
