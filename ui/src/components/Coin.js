import { formatUnits, parseUnits } from 'ethers'
import Spinner from './Spinner'
import ErrorButton from './ErrorButton'
import useCoinPrice from '../hooks/useCoinPrice'
import { COINS } from '../constants/coins'
import '../styles/coin.css'

const CoinIcon = ({ currency }) => {
  const coin = COINS[currency]

  if (!coin) {
    return <div>Unknown Coin</div>
  }

  const iconName = coin.icon

  return (
    <img
        src={`/images/icons/${iconName}.svg`}
        alt={`${coin.name}`}
        width="32"
        height="32"
    />
  )
}

export default function Coin({ chainId, currency, value }) {
  const {
    price,
    loading: priceLoading,
    error: priceError,
    decimals: priceDecimals,
  } = useCoinPrice({
    chainId: 1,
    currency,
  })

  const decimals = COINS[currency]?.decimals ?? 18
  const amount = parseUnits(value, decimals)

  return (
    <div className="coin">
      <CoinIcon currency={currency} />
      <div className="value">
        {(price || priceLoading || priceError) && (
          <div className="price">
            {price && !priceLoading && !priceError && (
              <div className="price">
                ${formatUnits(String(price * amount), decimals + priceDecimals)}
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
