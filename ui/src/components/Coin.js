import { formatUnits, parseUnits } from 'ethers'
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
        {(price || priceLoading || priceError) && (
          <div className="price">
            {price && !priceLoading && !priceError && (
              <div className="price">
                ${formatUnits(amount * price, decimals)}
              </div>
            )}
            {priceLoading && !priceError && <Spinner size={12} />}
            {priceError && !priceLoading && <ErrorButton message={priceError} />}
          </div>
        )}
        <div className="amount">{formatUnits(amount, decimals)} {currency}</div>
      </div>
    </div>
  )
}
