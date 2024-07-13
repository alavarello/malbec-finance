import DropDown from './DropDown'

function TokenDropDown({ selectedToken, tokens, onSelectToken }) {
  function tokenDisplay(token) {
    return (
      <div className="token-item">
        <div className="token-icon" />
        <div>{`${token.symbol} - ${token.name}`}</div>
      </div>
    );
  }

  return (
    <DropDown
      selectedItem={selectedToken}
      items={tokens.map(token => ({ ...token, display: tokenDisplay(token), displayName: `${token.symbol} - ${token.name}` }))}
      onSelectItem={onSelectToken}
    />
  );
}

export default TokenDropDown;
