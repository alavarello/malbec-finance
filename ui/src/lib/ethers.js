import { ethers } from 'ethers'

export const PROVIDERS = {
  1: ethers.getDefaultProvider('https://cloudflare-eth.com'),
  11155111: ethers.getDefaultProvider('https://rpc.sepolia.org'),
}
