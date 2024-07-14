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
import { LENDERS } from '../lib/lender'
import { calculateMax, getCoinPrice } from '../utils/pool'

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
  const [success, setSuccess] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

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
        selectedCondition.key,
        borrowToken.symbol,
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
    validateTokens(borrowToken, collateralToken) &&
    LENDERS[chainId]
  )

  const borrowSubmit = () => {
    setLoading(true)
    LENDERS[chainId].borrow(
      collateralToken.address[chainId],
      collateralAmount,
      borrowToken.address[chainId],
      borrowAmount,
      String(parseUnits(targetPrice, 2))
    ).then(() => {
      setSuccess(true)
    }).catch((err) => {
      setError(new Error(`Could not borrow: ${err}`))
    }).finally(() => {
      setLoading(false)
    })
  }

  return (
    <div>
      <Card>
        {success && <SuccessMessage>Your borrow has been success!</SuccessMessage>}
        {!success && (
          <div className="borrow-container">
            {loading && !error && <Spinner size={96} />}
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
                  max={calculateMax(pool, collateralAmount, borrowToken?.symbol)}
                />
                <InputNumber
                  value={collateralAmount}
                  onValue={(value) => setCollateralAmount(value)}
                  max={calculateMax(pool, borrowAmount, collateralToken?.symbol)}
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
            {error && !loading && <ErrorButton message={error} />}
            <div className="actions">
              <button disabled={!isBorrowValid} onClick={() => borrowSubmit()}>Borrow</button>
            </div>
            {!isConnected && (
              <div className="error">Connect your wallet to Borrow</div>
            )}
          </div>
        )}
      </Card>
    </div>
  )
}
