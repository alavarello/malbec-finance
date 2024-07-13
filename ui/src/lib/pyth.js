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
console.debug(PYTH)

// Prices should be from COIN/USD
export const PRICE_FEED_IDS = {
  ETH: '0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace',
  DAI: '0xb0948a5e5313200c632b51bb5ca32f6de0d36e9950a942d19751e833f70dabfd',
}
