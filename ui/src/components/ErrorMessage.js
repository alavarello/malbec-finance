import Card from './Card'

export default function ErrorMessage({ onClose, onRetry, message }) {
  return (
    <Card>
      <span className="error">{`${message}`}</span>
      {(onClose || onRetry) && (
        <div className="actions">
          {onClose && (
            <button onClick={onClose}>Close</button>
          )}
          {onRetry && (
            <button onClick={onRetry}>Retry</button>
          )}
        </div>
      )}
    </Card>
  )
}
