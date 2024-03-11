import React from "react";
import CardArt from "./CardArt";

const CardArtRow = ({cardArts}) => {
  return (
      <div className="card-art-row no-gutters" style={{"--num-cards": cardArts.length}}>
        {cardArts.map((cardArt) => <CardArt key={cardArt.id} cardArt={cardArt}/>)}
      </div>
  );
};

export default CardArtRow;
