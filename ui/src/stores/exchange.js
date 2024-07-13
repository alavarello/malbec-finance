import { createContext, useContext, useMemo, useState } from 'react'
import { EXCHANGES } from '../constants/exchanges'

export const ExchangeContext = createContext({
  exchange: EXCHANGES.UNISWAP,
  toggleExchange: () => {},
})

export const useExchange = () => useContext(ExchangeContext)

export function ExchangeProvider({ children, defaultExchange }) {
  const [exchange, setExchange] = useState(defaultExchange)

  const toggleExchange = () => {
    setExchange((prevExchange) => {
      if (prevExchange === EXCHANGES.UNISWAP) {
        return EXCHANGES.PANCAKESWAP
      }
      return EXCHANGES.UNISWAP
    })
  }

  const value = useMemo(() => ({
    exchange,
    toggleExchange,
  }), [
    exchange,
    toggleExchange,
  ])

  return (
    <ExchangeContext.Provider value={value}>
      {children}
    </ExchangeContext.Provider>
  )
}
