import TokenDropDown from './TokenDropDown'

export default function TokenPairDropDown({
  selectedFromToken,
  onSelectedFromToken,
  selectedToToken,
  onSelectedToToken,
}) {
  return (
    <div className="token-pair-selector-container">
      <TokenDropDown
        selectedToken={selectedFromToken}
        onSelectToken={onSelectedFromToken}
      />
      <TokenDropDown
        selectedToken={selectedToToken}
        onSelectToken={onSelectedToToken}
      />
    </div>
  )
}
