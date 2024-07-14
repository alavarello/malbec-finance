import { ethers } from 'ethers'

export const PROVIDERS = {
  1: ethers.getDefaultProvider('https://rpc.ankr.com/eth'),
  11155111: ethers.getDefaultProvider('https://rpc.sepolia.org'),
  31337: ethers.getDefaultProvider('http://127.0.0.1:8545'),
}
