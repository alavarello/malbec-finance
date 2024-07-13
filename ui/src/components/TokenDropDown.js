import DropDown from './DropDown'
import TokenDisplay from './TokenDisplay'
import { COINS } from '../constants/coins'

export default function TokenDropDown({ selectedToken, onSelectToken }) {
  const items = Object.entries(COINS).map(([symbol, token]) => ({
    symbol,
    name: token.name,
    key: `${symbol} - ${token.name}`,
    display: <TokenDisplay symbol={symbol} name={token.name} />,
  }))

  return (
    <DropDown
      items={items}
      selectedItem={selectedToken}
      onSelectItem={onSelectToken}
    />
  )
}
