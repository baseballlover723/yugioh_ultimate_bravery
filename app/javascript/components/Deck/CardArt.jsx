import React from "react";

const CardArt = ({cardArt}) => {
  return (
      <span className="card-art">
        <img src={`/${cardArt.smallPath}`} alt={cardArt.card.name}/>
      </span>
  );
};

export default CardArt;
