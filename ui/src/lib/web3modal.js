import { createWeb3Modal, defaultConfig } from '@web3modal/ethers/react'
import { CHAINS, DEFAULT_CHAIN_ID, DEFAULT_RPC_URL } from '../constants/chains'

const projectId = process.env.REACT_APP_WALLET_CONNECT_PROJECT_ID

const metadata = {
  name: 'Malbec Finance',
  description: 'AMM-Lending',
  url: 'https://localhost:3000',
  icons: [],
}

const ethersConfig = defaultConfig({
  metadata,
  rpcUrl: DEFAULT_RPC_URL,
  defaultChainId: DEFAULT_CHAIN_ID,
})

const modal = createWeb3Modal({
  ethersConfig,
  chains: CHAINS,
  projectId,
  enableAnalytics: false,
  enableOnramp: false,
})

export default modal
