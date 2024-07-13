import { useWallet } from '../stores/wallet'

export default function WalletConnect() {
  const { address, isConnected, connect, disconnect } = useWallet()

  return (
    <div className="wallet-connect">
      {isConnected ? (
        <>
          <span className="address">
            {address.substr(0, 6)}...{address.substr(-4)}
          </span>
          <button onClick={() => disconnect()}>
            Disconnect
          </button>
        </>
      ) : (
        <button onClick={() => connect()}>
          Connect Wallet
        </button>
      )}
    </div>
  )
}
