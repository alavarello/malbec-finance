export const DEFAULT_CHAIN_ID = 1
export const DEFAULT_RPC_URL = 'https://rpc.ankr.com/eth'

const mainnet = {
  uniswapKey: 'ETHEREUM',
  chainId: 1,
  name: 'Ethereum',
  currency: 'ETH',
  explorerUrl: 'https://eth.blockscout.com',
  rpcUrl: 'https://rpc.ankr.com/eth',
}

const sepolia = {
  uniswapKey: 'SEPOLIA',
  chainId: 11155111,
  name: 'Ethereum Sepolia',
  currency: 'ETH',
  explorerUrl: 'https://eth-sepolia.blockscout.com',
  rpcUrl: 'https://rpc.sepolia.org',
}

const localhost = {
  uniswapKey: 'LOCALHOST',
  chainId: 311337,
  name: 'Localhost',
  currency: 'ETH',
  explorerUrl: '',
  rpcUrl: 'http://127.0.0.1:8545',
}

export const CHAINS = [mainnet, sepolia, localhost]
