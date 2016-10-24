import React from 'react'
export const Divider = (props) => {
  return(
    <div className="divider">
      <h5>{props.text}</h5>
      <hr />
    </div>
  )
}
