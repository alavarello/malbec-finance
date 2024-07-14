export default function InputNumber({ value, onValue, max }) {
  return (
    <div className="input-number">
      <input
        type="number"
        value={value}
        onChange={(event) => onValue(event.target.value)}
        placeholder="Enter amount"
        className="number-input"
        max={max}
      />
      {max && max !== value && (
        <span className="input-number-max">
          Max: <button onClick={() => onValue(max)}>{max}</button>
        </span>
      )}
    </div>
  )
}
