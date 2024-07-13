import Coin from './Coin'
import Interest from './Interest'
import Liquidation from './Liquidation'

export default function Position({
  borrower,
  pool,
  colateral,
  debt,
  interest,
}) {
  return (
    <div className="position">
      <div className="position-header">
        <div className="position-tokens">
          <div className="position-token">
            <div className="position-token-info">
              <div className="title">Colateral</div>
              <Coin
                chainId={colateral.chainId}
                currency={colateral.currency}
                value={colateral.value}
              />
            </div>
            <Liquidation
              price={colateral.liquidation.price}
              currency={colateral.currency}
              lendingCondition={colateral.liquidation.lendingCondition}
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
        {/* <div className="position-liquidation">
          <Liquidation
            price={liquidation.price}
            currency={colateral.currency}
            lendingCondition={liquidation.lendingCondition}
          />
        </div> */}
      </div>
    </div>
  )
}
