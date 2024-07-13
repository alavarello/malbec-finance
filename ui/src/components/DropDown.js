import React, { useState } from 'react'

export default function DropDown({ items, selectedItem, onSelectItem }) {
  let [isOpen, setIsOpen] = useState(false)

  function toggleDropdown() {
    setIsOpen(!isOpen)
  }

  function handleSelectItem(item) {
    onSelectItem(item)
    setIsOpen(false)
  }

  return (
    <div className="dropdown-select">
      <button onClick={toggleDropdown} className="dropdown-select-button">
        <div>{selectedItem ? selectedItem.display : "Select"}</div>
      </button>
      {isOpen && (
        <div className="dropdown-menu">
          <ul>
            {items.map((item) => (
              <li key={item.key} onClick={() => handleSelectItem(item)}>
                {item.display}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
