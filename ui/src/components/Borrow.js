import { useState } from 'react'
import Card from './Card'
import DropDown from './DropDown'
import TokenPairDropDown from './TokenPairDropDown'
import ExchangeSelector from './ExchangeSelector'
import { LENDING_CONDITIONS } from '../constants/lending'
import { EXCHANGES } from '../constants/exchanges'

export default function Borrow({ onClose }) {
  const [borrowToken, setBorrowToken] = useState(null)
  const [collateralToken, setCollateralToken] = useState(null)
  const [selectedCondition, setSelectedCondition] = useState(null)
  const [selectedExchange, setSelectedExchange] = useState(EXCHANGES.UNISWAP)
  const [targetPrice, setTargetPrice] = useState('')

  const validateTokens = (fromToken, toToken) => {
    return fromToken && toToken && fromToken.symbol !== toToken.symbol
  }

  const isBorrowValid = validateTokens(borrowToken, collateralToken) && selectedCondition && targetPrice

  const handleTargetPriceChange = (event) => {
    setTargetPrice(event.target.value)
  }

  return (
    <div>
      <Card>
        <div className="borrow-container">
          <ExchangeSelector
            selectedExchange={selectedExchange}
            onSelectExchange={setSelectedExchange}
          />
          <div className="borrow-token-titles">
            <div>Borrow</div>
            <div>Collateral</div>
          </div>
          <TokenPairDropDown
            selectedFromToken={borrowToken}
            onSelectedFromToken={setBorrowToken}
            selectedToToken={collateralToken}
            onSelectedToToken={setCollateralToken}
          />
          <div className="input-group">
            <label>By:</label>
            <DropDown
              items={Object.values(LENDING_CONDITIONS).map((lendingCondition) => ({
                key: lendingCondition,
                display: lendingCondition,
              }))}
              selectedItem={selectedCondition}
              onSelectItem={setSelectedCondition}
            />
          </div>
          <div className="input-group">
            <label>Target Price:</label>
            <input
              type="number"
              value={targetPrice}
              onChange={handleTargetPriceChange}
              placeholder="Enter target price"
              className="target-price-input"
            />
            {borrowToken && collateralToken && (
              <div className="selected-tokens">
                {collateralToken.symbol} / {borrowToken.symbol} ({collateralToken.symbol} in terms of {borrowToken.symbol})
              </div>
            )}
          </div>
          <div className="actions">
            <button disabled={!isBorrowValid} onClick={() => alert('Borrow request submitted!')}>Borrow</button>
          </div>
        </div>
      </Card>
    </div>
  )
}
