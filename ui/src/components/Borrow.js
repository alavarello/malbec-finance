import { useState } from 'react'
import Card from './Card'
import DropDown from './DropDown'
import TokenPairDropDown from './TokenPairDropDown'
import { LENDING_CONDITIONS } from '../constants/lending'
import ExchangeSelector from "./ExchangeSelector";


export default function Borrow({ onClose }) {
  const [borrowToken, setBorrowToken] = useState(null);
  const [collateralToken, setCollateralToken] = useState(null);
  const [selectedCondition, setSelectedCondition] = useState(null);
  const [selectedExchange, setSelectedExchange] = useState('uniswap');
  const [targetPrice, setTargetPrice] = useState('');

  const validateTokens = (fromToken, toToken) => {
    return fromToken && toToken && fromToken.symbol !== toToken.symbol;
  };

  const isBorrowValid = validateTokens(borrowToken, collateralToken) && selectedCondition && targetPrice;

  const handleTargetPriceChange = (event) => {
    setTargetPrice(event.target.value);
  };

  return (
    <div>
      <Card>
        <div className="borrow-container">
          <ExchangeSelector onSelectItem={setSelectedExchange} defaultSelectedItem={'uniswap'} onClose={onClose} />
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
              selectedItem={selectedCondition}
              items={Object.values(LENDING_CONDITIONS)}
              onSelectItem={setSelectedCondition}
              renderItem={(condition) => <div>{condition}</div>}
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
        </div>
      </Card>
    </div>
  )
}
