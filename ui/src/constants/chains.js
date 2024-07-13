export const DEFAULT_CHAIN_ID = 1
export const DEFAULT_RPC_URL = 'https://cloudflare-eth.com'

const mainnet = {
  chainId: 1,
  name: 'Ethereum',
  currency: 'ETH',
  explorerUrl: 'https://eth.blockscout.com',
  rpcUrl: 'https://cloudflare-eth.com',
}

const sepolia = {
  chainId: 11155111,
  name: 'Ethereum Sepolia',
  currency: 'ETH',
  explorerUrl: 'https://eth-sepolia.blockscout.com',
  rpcUrl: 'https://rpc.sepolia.org',
}

export const CHAINS = [mainnet, sepolia]
