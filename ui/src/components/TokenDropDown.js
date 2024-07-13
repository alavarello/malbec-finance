import DropDown from './DropDown'
import TokenDisplay from './TokenDisplay'

function TokenDropDown({ selectedToken, tokens, onSelectToken }) {
  return (
    <DropDown
      selectedItem={selectedToken}
      items={tokens.map(token => ({ ...token, display: <TokenDisplay token={token} />, displayName: `${token.symbol} - ${token.name}` }))}
      onSelectItem={onSelectToken}
    />
  );
}

export default TokenDropDown;
