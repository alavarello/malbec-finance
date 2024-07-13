import { createContext, useContext, useMemo, useState } from 'react'
import { useWeb3Modal, useWeb3ModalAccount } from '@web3modal/ethers/react'

const WalletContext = createContext({
  chainId: 1,
  address: null,
  isConnected: false,
  connect() {},
  disconnect() {},
})

export const useWallet = () => useContext(WalletContext)

export function WalletProvider({ children, defaultChainId = 1 }) {
  const [disconnected, setDisconnected] = useState(true)
  const { open } = useWeb3Modal()
  const { chainId, isConnected, address } = useWeb3ModalAccount()

  function connect() {
    setDisconnected(false)
    if (!isConnected) {
      open({ view: 'Connect' })
    }
  }

  function disconnect() {
    setDisconnected(true)
  }

  const value = useMemo(() => ({
    chainId: chainId ?? defaultChainId,
    address: isConnected && !disconnected ? address : null,
    isConnected: isConnected && !disconnected,
    connect,
    disconnect,
  }), [
    chainId,
    address,
    isConnected,
    connect,
    disconnected,
    disconnect,
  ])

  return (
    <WalletContext.Provider value={value}>
      {children}
    </WalletContext.Provider>
  )
}
