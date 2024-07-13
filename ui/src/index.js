import ReactDOM from 'react-dom/client'
import ExchangeSelector from './components/ExchangeSelector'
import WalletConnect from './components/WalletConnect'
import ButtonModal from './components/ButtonModal'
import Lend from './components/Lend'
import Borrow from './components/Borrow'
import PositionList from './components/PositionList'
import { ReactComponent as Wine } from './assets/Wine.svg'
import { ReactComponent as Barrel } from './assets/Barrel.svg'
import { WalletProvider } from './stores/wallet'
import { ExchangeProvider } from './stores/exchange'
import { DEFAULT_CHAIN_ID } from './constants/chains'
import { EXCHANGES } from './constants/exchanges'
import './lib/web3modal'
import './styles/index.css'

const root = ReactDOM.createRoot(
  document.getElementById('root'),
)

root.render(
  <WalletProvider defaultChainId={DEFAULT_CHAIN_ID}>
    <ExchangeProvider defaultExchange={EXCHANGES.UNISWAP}>
      <header>
        <h1>Malbec Finance</h1>
        <div className="user">
          <ExchangeSelector />
          <WalletConnect />
        </div>
      </header>
      <main>
        <div className="malbec">
          <ButtonModal className="cta" modal={Lend}>
            <Barrel />
            <span>Lending</span>
          </ButtonModal>
          <ButtonModal className="cta" modal={Borrow}>
            <Wine />
            <span>Borrowing</span>
          </ButtonModal>
        </div>
        <PositionList />
      </main>
    </ExchangeProvider>
  </WalletProvider>
)
