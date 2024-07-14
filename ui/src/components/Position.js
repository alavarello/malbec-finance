import Coin from './Coin'
import Interest from './Interest'
import Liquidation from './Liquidation'

export default function Position({
  borrower,
  pool,
  collateral,
  debt,
  interest,
}) {
  return (
    <div className="position">
      <div className="position-header">
        <div className="position-tokens">
          <div className="position-token">
            <div className="position-token-info">
              <div className="title">Collateral</div>
              <Coin
                chainId={collateral.chainId}
                currency={collateral.currency}
                value={collateral.value}
              />
            </div>
            <Liquidation
              price={collateral.liquidation.price}
              currency={collateral.currency}
              lendingCondition={collateral.liquidation.lendingCondition}
            />
          </div>
          <div className="position-token">
            <div className="position-token-info">
              <div className="title">Debt</div>
              <Coin
                chainId={debt.chainId}
                currency={debt.currency}
                value={debt.value}
              />
            </div>
            <Liquidation
              price={debt.liquidation.price}
              currency={debt.currency}
              lendingCondition={debt.liquidation.lendingCondition}
            />
          </div>
        </div>
        <button className="repay">Repay</button>
      </div>
      <div className="position-footer">
        <Interest rate={interest.rate} fee={interest.fee} />
      </div>
    </div>
  )
}
