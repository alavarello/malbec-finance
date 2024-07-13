export default function TokenDisplay({ symbol, name, icon }) {
  return (
      <div className="token-item">
        <div className="token-icon">
          <img src={`/images/icons/${icon}.svg`} alt={`${symbol} icon`} />
        </div>
        <div className="token-info">
          <div className="token-symbol">{symbol}</div>
          <div className="token-name">{name}</div>
        </div>
      </div>
  )
}