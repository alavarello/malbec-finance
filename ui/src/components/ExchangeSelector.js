import { useExchange } from '../stores/exchange'
import ExchangeToggle from './ExchangeToggle'

export default function ExchangeSelector() {
  const { exchange, toggleExchange } = useExchange()

  return (
    <ExchangeToggle
      selectedExchange={exchange}
      onSelectExchange={toggleExchange}
    />
  )
}
