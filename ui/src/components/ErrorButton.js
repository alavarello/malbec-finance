import ButtonModal from './ButtonModal'
import ErrorMessage from './ErrorMessage'

export default function ErrorButton({ message, onRetry }) {
  if (!message) {
    return null
  }
  return (
    <ButtonModal
      className="error-button"
      modal={ErrorMessage}
      message={message}
      onRetry={onRetry}
    >
      ⚠️
    </ButtonModal>
  )
}
