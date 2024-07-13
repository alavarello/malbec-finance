import React, { useState } from 'react';

export default function DropDown({ selectedItem, items, onSelectItem }) {
  let [isOpen, setIsOpen] = useState(false);

  function toggleDropdown() {
    setIsOpen(!isOpen);
  }

  function handleSelectItem(item) {
    onSelectItem(item);
    setIsOpen(false);
  }

  return (
    <div className="dropdown-select">
      <button onClick={toggleDropdown} className="dropdown-select-button">
        <div>{selectedItem ? (selectedItem?.displayName ?? selectedItem) : "Select"}</div>
      </button>
      {isOpen && (
        <div className="dropdown-menu">
          <ul>
            {items.map((item) => (
              <li key={item.displayName} onClick={() => handleSelectItem(item)}>
                { item.display ?? item }
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
