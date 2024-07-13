import { tokens } from '../constants/tokens'
import TokenDropDown from './TokenDropDown'

export default function TokenPairDropDown({
  selectedFromToken,
  onSelectedFromToken,
  selectedToToken,
  onSelectedToToken
}) {
  return (
    <div className="token-pair-selector-container">
      <TokenDropDown selectedToken={selectedFromToken} tokens={tokens} onSelectToken={onSelectedFromToken}/>
      <TokenDropDown selectedToken={selectedToToken} tokens={tokens} onSelectToken={onSelectedToToken}/>
    </div>
  )
}
