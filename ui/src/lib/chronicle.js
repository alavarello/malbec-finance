// Contract addresses must be from a coin to USD per chain
// https://docs.chroniclelabs.org/hackathons/eth-global-brussels-hackathon
export const CHRONICLE_ADDRESSES = {
  1: {
  },
  11155111: {
    ETH: '0xdd6D76262Fd7BdDe428dcfCd94386EbAe0151603',
    DAI: '0xaf900d10f197762794C41dac395C5b8112eD13E1',
    USDC: '0xb34d784dc8E7cD240Fe1F318e282dFdD13C389AC',
    WBTC: '0xdc3ef3E31AdAe791d9D5054B575f7396851Fa432',
    WETH: '0xdc3ef3E31AdAe791d9D5054B575f7396851Fa432',
  },
}

const CHRONICLE_ABI = [
  {
    "inputs": [],
    "name": "read",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "readWithAge",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "age",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "tryRead",
    "outputs": [
      {
        "internalType": "bool",
        "name": "isValid",
        "type": "bool"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "tryReadWithAge",
    "outputs": [
      {
        "internalType": "bool",
        "name": "isValid",
        "type": "bool"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "age",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "wat",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "wat",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]

export const CHRONICLE = Object.fromEntries(
  Object.entries(CHRONICLE_ADDRESSES)
    .filter(([chainId]) => PROVIDERS[chainId])
    .map(([chainId, addressesByCoin]) =>
      [chainId, Object.fromEntries(
        Object.entries(addressesByCoin).map(([currency, contractAddress]) =>
          [currency, new ethers.Contract(
            contractAddress,
            CHRONICLE_ABI,
            PROVIDERS[chainId]
          )]
        )
      )]
    )
)
