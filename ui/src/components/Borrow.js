import { useState } from 'react'
import Card from './Card'
import DropDown from './DropDown'
import TokenPairDropDown from './TokenPairDropDown'
import ExchangeToggle from './ExchangeToggle'
import { LENDING_CONDITIONS } from '../constants/lending'
import { useExchange } from '../stores/exchange'
import { useWallet } from '../stores/wallet'

export default function Borrow({ onClose }) {
  const { exchange } = useExchange()
  const { isConnected } = useWallet()

  const [borrowToken, setBorrowToken] = useState(null)
  const [collateralToken, setCollateralToken] = useState(null)
  const [selectedCondition, setSelectedCondition] = useState(null)
  const [selectedExchange, setSelectedExchange] = useState(exchange)
  const [targetPrice, setTargetPrice] = useState('')

  const validateTokens = (fromToken, toToken) => {
    return fromToken && toToken && fromToken.symbol !== toToken.symbol
  }

  const isBorrowValid = isConnected && validateTokens(borrowToken, collateralToken) && selectedCondition && targetPrice

  const handleTargetPriceChange = (event) => {
    setTargetPrice(event.target.value)
  }

  return (
    <div>
      <Card>
        <div className="borrow-container">
          <ExchangeToggle
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
            <button disabled={!isBorrowValid} onClick={() => alert('Borrow request submitted!')}>Submit</button>
          </div>
          {!isConnected && (
            <div className="error">Connect your wallet to Borrow</div>
          )}
        </div>
      </Card>
    </div>
  )
}
