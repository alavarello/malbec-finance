import { ReactComponent as UniswapLogo } from '../assets/Uniswap.svg'
import { ReactComponent as PancakeSwapLogo } from '../assets/Pancakeswap.svg'
import { EXCHANGES } from '../constants/exchanges'

export default function ExchangeToggle({ selectedExchange, onSelectExchange }) {
  const toggleExchange = () => {
    const newExchange = selectedExchange === EXCHANGES.UNISWAP
      ? EXCHANGES.PANCAKESWAP
      : EXCHANGES.UNISWAP

    onSelectExchange(newExchange)
  }

  return (
    <div className="exchange-selector-container">
      <label className="exchange-selector-toggle-switch">
        <input
          type="checkbox"
          checked={selectedExchange === EXCHANGES.PANCAKESWAP}
          onChange={toggleExchange}
        />
        <span className="exchange-selector-slider">
          <span className="exchange-selector-logo">
            {selectedExchange === EXCHANGES.UNISWAP ? <UniswapLogo /> : <PancakeSwapLogo />}
          </span>
        </span>
      </label>
    </div>
  )
}
