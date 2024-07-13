import React, { useState } from 'react';
import { ReactComponent as UniswapLogo } from '../assets/uniswap.svg'
import { ReactComponent as PancakeSwapLogo } from '../assets/pancakeswap.svg'
const ExchangeSelector = ({ onSelectItem, defaultSelectedItem }) => {
    const [selectedExchange, setSelectedExchange] = useState(defaultSelectedItem);

    const toggleExchange = () => {
        const newExchange = selectedExchange === 'uniswap' ? 'pancakeswap' : 'uniswap';
        setSelectedExchange(newExchange);
        onSelectItem(newExchange);
    };

    return (
        <div className="exchange-selector-container">
            <label className="exchange-selector-toggle-switch">
                <input
                    type="checkbox"
                    checked={selectedExchange === 'pancakeswap'}
                    onChange={toggleExchange}
                />
                <span className="exchange-selector-slider">
          <span className="exchange-selector-logo">
            {selectedExchange === 'uniswap' ? <UniswapLogo /> : <PancakeSwapLogo />}
          </span>
        </span>
            </label>
        </div>
    );
};

export default ExchangeSelector;