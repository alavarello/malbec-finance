import { ethers } from 'ethers'
import { PROVIDERS } from './ethers'
import PYTH_ABI from '@pythnetwork/pyth-sdk-solidity/abis/IPyth.json'

export const CONTRACT_ADDRESSES = {
  1: '0x4305FB66699C3B2702D4d05CF36551390A4c69C6',
  11155111: '0xDd24F84d36BF92C65F92307595335bdFab5Bbd21',
}

export const PYTH = Object.fromEntries(
  Object.entries(CONTRACT_ADDRESSES)
    .filter(([chainId]) => PROVIDERS[chainId])
    .map(([chainId, contractAddress]) =>
      [chainId, new ethers.Contract(contractAddress, PYTH_ABI, PROVIDERS[chainId])]
    )
)

// Prices should be from COIN/USD
// https://pyth.network/developers/price-feed-ids
export const PRICE_FEED_IDS = {
  ETH: '0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace',
  DAI: '0xb0948a5e5313200c632b51bb5ca32f6de0d36e9950a942d19751e833f70dabfd',
  USDC: '0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a',
  WETH: '0x9d4294bbcd1174d6f2003ec365831e64cc31d9f6f15a2b85399db8d5000960f6',
  WBTC: '0xc9d8b075a5c69303365ae23633d4e085199bf5c520a3b90fed1322a0342ffc33',
}
