import { CHAINS } from '../constants/chains'

export function getUniswapChainKey(chainId) {
  const chain = CHAINS.find((chain) => chain.chainId === chainId)
  if (chain) {
    return chain.uniswapKey
  }
  return null
}
