import { formatUnits } from 'ethers'
import { COINS } from '../constants/coins'

export default function Liquidation({ price, currency, lendingCondition }) {
  const decimals = COINS[currency]?.decimals ?? 18

  return (
    <div className="liquidation">
      Liq. {formatUnits(price, decimals)} {currency}
    </div>
  )
}
