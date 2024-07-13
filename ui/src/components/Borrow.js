import Card from './Card'
import TokenPairDropDown from './TokenPairDropDown'

export default function Borrow({ onClose }) {

  return (
    <div>
      <>Borrow</>
      <Card>
        <TokenPairDropDown />
      </Card>
    </div>
  )
}
