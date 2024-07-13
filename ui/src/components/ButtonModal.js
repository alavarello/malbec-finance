import { useState } from 'react'
import { createPortal } from 'react-dom'

export default function ButtonModal({ className, children, modal: Modal }) {
  const [showModal, setShowModal] = useState()

  const open = () => setShowModal(true)
  const close = () => setShowModal(false)

  return (
    <>
      <button className={className} onClick={() => open()}>
        {children}
      </button>
      {showModal && createPortal(
        <div className="overlay" onClick={() => close()}>
          <Modal onClose={() => close()} />
        </div>,
        document.body
      )}
    </>
  )
}
