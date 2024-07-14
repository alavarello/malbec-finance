import { useEffect, useState } from 'react'
import Card from './Card'
import DropDown from './DropDown'
import TokenPairDropDown from './TokenPairDropDown'
import ExchangeToggle from './ExchangeToggle'
import { LENDING_CONDITIONS } from '../constants/lending'
import { useExchange } from '../stores/exchange'
import { useWallet } from '../stores/wallet'
import useLendingPool from '../hooks/useLendingPool'
import { calculateAvailableTokens, fromDecimals } from '../utils/liquidity'
// import { Bar, BarChart, Cell, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { COINS } from '../constants/coins'
import {EthersLender} from "../lib/lender";

export default function Borrow({ onClose }) {
  const { exchange } = useExchange()
  const { isConnected } = useWallet()

  const [borrowToken, setBorrowToken] = useState(null)
  const [collateralToken, setCollateralToken] = useState(null)
  const [selectedCondition, setSelectedCondition] = useState(null)
  const [selectedExchange, setSelectedExchange] = useState(exchange)
  const [targetPrice, setTargetPrice] = useState('')
  const [availableLiquidity, setAvailableLiquidity] = useState(0);
  // const [processedTicks, setProcessedTicks] = useState([]);

  const pool = useLendingPool({ currency0: borrowToken?.symbol, currency1: collateralToken?.symbol });

  useEffect(() => {
    if (pool && selectedCondition && targetPrice) {
      const liquidity = calculateAvailableTokens(
        pool,
        parseFloat(targetPrice),
        selectedCondition.key,
        borrowToken.symbol,
      );

      setAvailableLiquidity(fromDecimals(liquidity, COINS[borrowToken.symbol].decimals));
      setProcessedTicks(processTicksForChart(pool, borrowToken.symbol));
    }
  }, [pool, selectedCondition, targetPrice]);

  const validateTokens = (fromToken, toToken) => {
    return fromToken && toToken && fromToken.symbol !== toToken.symbol
  }

  const isBorrowValid = true // isConnected && validateTokens(borrowToken, collateralToken) && selectedCondition && targetPrice

  const handleTargetPriceChange = (event) => {
    setTargetPrice(event.target.value)
  }

  const borrowSubmit = () => {
    EthersLender[31337].borrow(
        collateralToken.address,
        10,
        borrowToken.address,
        100,
        4000
    )
  }

  return (
    <div>
      <Card>
        <div className="borrow-container">
          <ExchangeToggle
            selectedExchange={selectedExchange}
            onSelectExchange={setSelectedExchange}
          />
          <div className="borrow-token-titles">
            <div>Borrow</div>
            <div>Collateral</div>
          </div>
          <TokenPairDropDown
            selectedFromToken={borrowToken}
            onSelectedFromToken={setBorrowToken}
            selectedToToken={collateralToken}
            onSelectedToToken={setCollateralToken}
          />
          <div className="input-group">
            <label>By:</label>
            <DropDown
              items={Object.values(LENDING_CONDITIONS).map((lendingCondition) => ({
                key: lendingCondition,
                display: lendingCondition,
              }))}
              selectedItem={selectedCondition}
              onSelectItem={setSelectedCondition}
            />
          </div>
          <div className="input-group">
            <label>Target Price:</label>
            <input
              type="number"
              value={targetPrice}
              onChange={handleTargetPriceChange}
              placeholder="Enter target price"
              className="target-price-input"
            />
            {borrowToken && collateralToken && (
              <div className="selected-tokens">
                {collateralToken.symbol} / {borrowToken.symbol} ({collateralToken.symbol} in terms of {borrowToken.symbol})
              </div>
            )}
            <div className="available-liquidity">
              <label>Available Liquidity:</label>
              <div>{availableLiquidity}</div>
            </div>
          </div>
          <div className="actions">
            <button disabled={!isBorrowValid} onClick={() => borrowSubmit()}>Borrow</button>
          </div>
          {!isConnected && (
            <div className="error">Connect your wallet to Borrow</div>
          )}
          {/*processedTicks && false && (
            <div className="liquidity-chart">
              <ResponsiveContainer width="80%" height={300}>
                <BarChart data={processedTicks}>
                  <XAxis
                    dataKey="price"
                    tickFormatter={(value) => value.toFixed(6)}
                  />
                  <YAxis
                    tickFormatter={(value) => value.toLocaleString()}
                  />
                  <Tooltip
                    formatter={(value) => value.toLocaleString()}
                    labelFormatter={(label) => `Price: ${label}`}
                  />
                  <Bar dataKey="liquidityActiveChart" fill="#2172E5">
                    {processedTicks.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.isActive ? '#F51E87' : '#2172E5'} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          )*/}
        </div>
      </Card>
    </div>
  )
}

// function processTicksForChart(pool, token) {
//   const currentTick = pool.ticks.find(tick => tick.tick === 0);
//
//   if (!currentTick) {
//     return [];
//   }
//
//   const currentTickIndex = currentTick.tick;
//   return pool.ticks.map(tick => ({
//     tickIdx: tick.tick - currentTickIndex,
//     liquidityActive: parseFloat(tick.liquidityNet),
//     liquidityNet: parseFloat(tick.liquidityNet),
//     price: parseFloat(pool.currency0 === token ? tick.price0 : tick.price1),
//     price0: parseFloat(tick.price0),
//     price1: parseFloat(tick.price1),
//     liquidityActiveChart: parseFloat(tick.liquidityNet),
//     isActive: tick.tick === currentTick.tick,
//   }));
// }
