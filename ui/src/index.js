import ReactDOM from 'react-dom/client'
import WalletConnect from './components/WalletConnect'
import { ReactComponent as Wine } from './assets/Wine.svg'
import { ReactComponent as Barrel } from './assets/Barrel.svg'
import { WalletProvider } from './stores/wallet'
import './lib/web3modal'
import './styles/index.css'

const root = ReactDOM.createRoot(
  document.getElementById('root'),
)

root.render(
  <WalletProvider>
    <header>
      <h1>Malbec Finance</h1>
      <WalletConnect />
    </header>
    <main>
      <div className="malbec">
        <button className="cta">
          <Barrel />
          <span>Lending</span>
        </button>
        <button className="cta">
          <Wine />
          <span>Borrowing</span>
        </button>
      </div>
    </main>
  </WalletProvider>
)
