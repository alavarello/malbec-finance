import { createWeb3Modal, defaultConfig } from '@web3modal/ethers/react'

const projectId = process.env.REACT_APP_WALLET_CONNECT_PROJECT_ID

const mainnet = {
  chainId: 1,
  name: 'Ethereum',
  currency: 'ETH',
  explorerUrl: 'https://eth.blockscout.com',
  rpcUrl: 'https://cloudflare-eth.com',
}

const metadata = {
  name: 'Malbec Finance',
  description: 'AMM-Lending',
  url: 'https://localhost:3000',
  icons: [],
}

const ethersConfig = defaultConfig({
  metadata,
  rpcUrl: 'https://cloudflare-eth.com',
  defaultChainId: 1,
})

const modal = createWeb3Modal({
  ethersConfig,
  chains: [mainnet],
  projectId,
  enableAnalytics: false,
  enableOnramp: false,
})

export default modal
