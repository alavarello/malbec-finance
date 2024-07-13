import { useState } from 'react'
import { useExchange } from '../stores/exchange'
import Card from './Card'
import ExchangeToggle from './ExchangeToggle'
import TokenPairDropDown from './TokenPairDropDown'
import { EXCHANGES, EXCHANGES_DOMAIN } from '../constants/exchanges'

export default function Lend({ onClose }) {
  const { exchange } = useExchange()

  const [leftToken, setLeftToken] = useState(null)
  const [rightToken, setRightToken] = useState(null)
  const [selectedExchange, setSelectedExchange] = useState(exchange)

  const validateTokens = (fromToken, toToken) => {
    return fromToken && toToken && fromToken.symbol !== toToken.symbol
  }

  const isLendValid = validateTokens(leftToken, rightToken)

  const handleSubmit = () => {
    window.open(
      `${EXCHANGES_DOMAIN[selectedExchange]}/add/${leftToken.symbol}/${rightToken.symbol}`,
      '_blank'
    )
  }

  return (
    <div>
      <Card>
        <div className="lend-container">
          <ExchangeToggle
            selectedExchange={selectedExchange}
            onSelectExchange={setSelectedExchange}
          />
          <div className="lend-title">
            Choose Token Pair
          </div>
          <TokenPairDropDown
            selectedFromToken={leftToken}
            onSelectedFromToken={setLeftToken}
            selectedToToken={rightToken}
            onSelectedToToken={setRightToken}
          />
          <div className="actions">
            <button disabled={!isLendValid} onClick={handleSubmit}>Lend</button>
          </div>
        </div>
      </Card>
    </div>
  )
}
