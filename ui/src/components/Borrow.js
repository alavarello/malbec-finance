import Card from './Card'
import TokenPairDropDown from './TokenPairDropDown'
import DropDown from './DropDown'
import { lendingConditions } from '../constants/tokens'
import { useState } from 'react'

export default function Borrow({ onClose }) {
  const [selectedFromToken, setSelectedFromToken] = useState(null);
  const [selectedToToken, setSelectedToToken] = useState(null);
  const [selectedCondition, setSelectedCondition] = useState(null);

  return (
    <div>
      <Card>
        <h2>Borrow</h2>
        <div className="borrow-container">
          <div className="borrow-token-titles">
            <div>Taking</div>
            <div>Collateral</div>
          </div>
          <TokenPairDropDown
            selectedFromToken={selectedFromToken}
            onSelectedFromToken={setSelectedFromToken}
            selectedToToken={selectedToToken}
            onSelectedToToken={setSelectedToToken}
          />
          By:
          <DropDown
            selectedItem={selectedCondition}
            items={lendingConditions}
            onSelectItem={setSelectedCondition}
            renderItem={(condition) => <div>{condition}</div>}
          />
          <div className="selected-tokens">
            {selectedFromToken?.symbol && selectedFromToken?.symbol && (
              `${selectedFromToken.symbol} / ${selectedToToken.symbol}`
            )}
          </div>
        </div>
      </Card>
    </div>
  )
}
