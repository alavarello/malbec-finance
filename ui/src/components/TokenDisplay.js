export default function TokenDisplay({ symbol, name }) {
  return (
    <div className="token-item">
    <div className="token-icon" />
      <div>{`${symbol} - ${name}`}</div>
    </div>
  )
}
