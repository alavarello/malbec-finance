import { useEffect, useState } from 'react'
import { formatUnits, parseUnits } from 'ethers'
import Card from './Card'
import Spinner from './Spinner'
import ErrorButton from './ErrorButton'
import DropDown from './DropDown'
import TokenPairDropDown from './TokenPairDropDown'
import ExchangeToggle from './ExchangeToggle'
import InputNumber from './InputNumber'
import { LENDING_CONDITIONS } from '../constants/lending'
import { useExchange } from '../stores/exchange'
import { useWallet } from '../stores/wallet'
import useLendingPool from '../hooks/useLendingPool'
import { calculateAvailableTokens } from '../utils/liquidity'
import { EthersLender } from '../lib/lender'
import { getCoinPrice } from '../utils/pool'

export default function Borrow({ onClose }) {
  const { exchange } = useExchange()
  const { isConnected, chainId } = useWallet()

  const [borrowToken, setBorrowToken] = useState(null)
  const [collateralToken, setCollateralToken] = useState(null)
  const [selectedCondition, setSelectedCondition] = useState(null)
  const [selectedExchange, setSelectedExchange] = useState(exchange)
  const [borrowAmount, setBorrowAmount] = useState('')
  const [collateralAmount, setCollateralAmount] = useState('')
  const [targetPrice, setTargetPrice] = useState('')
  const [availableLiquidity, setAvailableLiquidity] = useState(0)

  const {
    pool,
    loading: poolLoading,
    error: poolError,
  } = useLendingPool({
    chainId,
    currency0: borrowToken?.symbol,
    currency1: collateralToken?.symbol,
  })

  useEffect(() => {
    if (pool && selectedCondition && targetPrice) {
      const liquidity = calculateAvailableTokens(
        pool,
        parseUnits(targetPrice, 2),
        selectedCondition.key
      )

      setAvailableLiquidity(
        formatUnits(liquidity, 2)
      )
    }
  }, [pool, selectedCondition, targetPrice])

  const validateTokens = (fromToken, toToken) => {
    return fromToken && toToken && fromToken.symbol !== toToken.symbol
  }

  const isBorrowValid = (
    isConnected &&
    selectedCondition &&
    targetPrice &&
    collateralAmount &&
    borrowAmount &&
    validateTokens(borrowToken, collateralToken)
  )

  const borrowSubmit = () => {
    EthersLender[31337].borrow(
      collateralToken.address[31337],
      collateralAmount,
      borrowToken.address[31337],
      borrowAmount,
      String(parseUnits(targetPrice, 2))
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
          <div className="token-pair-container">
            <TokenPairDropDown
              selectedFromToken={borrowToken}
              onSelectedFromToken={setBorrowToken}
              selectedToToken={collateralToken}
              onSelectedToToken={setCollateralToken}
            />
            {poolLoading && !poolError && <Spinner />}
            {poolError && !poolLoading && <ErrorButton message={poolError} />}
            <div className="input-group-token">
              <InputNumber
                value={borrowAmount}
                onValue={(value) => setBorrowAmount(value)}
                max={!collateralAmount || !pool ? undefined : parseFloat(collateralAmount) * getCoinPrice(pool, borrowToken?.symbol)}
              />
              <InputNumber
                value={collateralAmount}
                onValue={(value) => setCollateralAmount(value)}
                max={!borrowAmount || !pool ? undefined : parseFloat(borrowAmount) * getCoinPrice(pool, collateralToken?.symbol)}
              />
            </div>
          </div>
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
              onChange={(event => setTargetPrice(event.target.value))}
              placeholder="Enter target price"
              className="number-input"
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
        </div>
      </Card>
    </div>
  )
}
