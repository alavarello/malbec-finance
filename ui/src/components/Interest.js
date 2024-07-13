import { formatUnits } from 'ethers'
import { COINS } from '../constants/coins'

export default function Interest({ rate, fee }) {
  if (!rate && !fee) {
    return null
  }

  return (
    <div className="interest">
      Interest:{' '}
      {rate && `${rate}%`}
      {rate && fee && ' / '}
      {fee && `${formatUnits(fee.value, COINS[fee.currency]?.decimals ?? 18)} ${fee.currency}`}
    </div>
  )
}
