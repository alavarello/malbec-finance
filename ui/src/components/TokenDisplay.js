function TokenDisplay({ token }) {
  return (
    <div className="token-item">
    <div className="token-icon" />
      <div>{`${token.symbol} - ${token.name}`}</div>
    </div>
  )
}

export default TokenDisplay;
