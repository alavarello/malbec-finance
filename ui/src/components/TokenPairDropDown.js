import { useState } from 'react'
import TokenDropDown from './TokenDropDown'
import { tokens } from '../constants/tokens'

export default function TokenPairDropDown({ onClose }) {
  const [selectedFromToken, setSelectedFromToken] = useState(null);
  const [selectedToToken, setSelectedToToken] = useState(null);

  return (
    <div className="token-selector-container">
      <TokenDropDown selectedToken={selectedFromToken} tokens={tokens} onSelectToken={setSelectedFromToken}/>
      <TokenDropDown selectedToken={selectedToToken} tokens={tokens} onSelectToken={setSelectedToToken}/>
    </div>
  )
}
