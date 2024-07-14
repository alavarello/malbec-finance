import { ethers } from 'ethers'
import { PROVIDERS } from './ethers'

const LENDER_ABI = [{"type":"constructor","inputs":[{"name":"initKey","type":"tuple","internalType":"struct PoolKey","components":[{"name":"currency0","type":"address","internalType":"Currency"},{"name":"currency1","type":"address","internalType":"Currency"},{"name":"fee","type":"uint24","internalType":"uint24"},{"name":"tickSpacing","type":"int24","internalType":"int24"},{"name":"hooks","type":"address","internalType":"contract IHooks"}]},{"name":"managerAddress","type":"address","internalType":"address"}],"stateMutability":"nonpayable"},{"type":"function","name":"borrow","inputs":[{"name":"collateralToken","type":"address","internalType":"address"},{"name":"amountOfCollateral","type":"uint256","internalType":"uint256"},{"name":"debtToken","type":"address","internalType":"address"},{"name":"amountOfDebt","type":"uint256","internalType":"uint256"},{"name":"poolLiquidationPrice","type":"uint256","internalType":"uint256"}],"outputs":[],"stateMutability":"nonpayable"},{"type":"function","name":"convertSqrtPriceX96ToPrice","inputs":[{"name":"sqrtPriceX96","type":"uint160","internalType":"uint160"}],"outputs":[{"name":"","type":"uint256","internalType":"uint256"}],"stateMutability":"pure"},{"type":"function","name":"getPrice","inputs":[{"name":"token0","type":"address","internalType":"address"},{"name":"token1","type":"address","internalType":"address"}],"outputs":[{"name":"","type":"uint256","internalType":"uint256"}],"stateMutability":"view"},{"type":"function","name":"positions","inputs":[{"name":"positionId","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"collateralToken","type":"address","internalType":"address"},{"name":"amountOfCollateral","type":"uint256","internalType":"uint256"},{"name":"debtToken","type":"address","internalType":"address"},{"name":"amountOfDebt","type":"uint256","internalType":"uint256"},{"name":"poolLiquidationPrice","type":"uint256","internalType":"uint256"},{"name":"rightLiquidity","type":"bool","internalType":"bool"}],"stateMutability":"view"},{"type":"function","name":"setHookAddress","inputs":[{"name":"newHookAddress","type":"address","internalType":"address"}],"outputs":[],"stateMutability":"nonpayable"}]

export const CONTRACT_ADDRESSES = {
  31337: '0xDB25A7b768311dE128BBDa7B8426c3f9C74f3240',
}

export const LENDERS = Object.fromEntries(
  Object.entries(CONTRACT_ADDRESSES)
    .filter(([chainId]) => PROVIDERS[chainId])
    .map(([chainId, contractAddress]) =>
      [chainId, new ethers.Contract(contractAddress, LENDER_ABI, PROVIDERS[chainId])]
    )
)
