import { LENDING_CONDITIONS } from '../constants/lending'

export default function usePositions({ chainId, address }) {
  return {
    positions: [
      {
        pool: {
          poolId: '0x0000',
          currency0: 'DAI',
          currency1: 'USDC',
        },
        colateral: {
          currency: 'ETH',
          value: '3',
          liquidation: {
            price: '3500000000000000000000000',
            lendingCondition: LENDING_CONDITIONS.Long,
          },
        },
        debt: {
          currency: 'USDC',
          value: '10000',
          liquidation: {
            price: '100000000000000000000',
            lendingCondition: LENDING_CONDITIONS.Short,
          },
        },
        interest: {
          rate: null,
          fee: {
            currency: 'ETH',
            value: '100000000000000000',
          },
        },
      },
    ],
    loading: false,
    error: null,
  }
}
