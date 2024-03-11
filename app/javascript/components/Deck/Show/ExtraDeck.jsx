import React from "react";
import CardArtRow from "../CardArtRow";

const ExtraDeck = ({cardArts}) => {
  return (
      <div className="extra-deck">
        <h4>Extra Deck ({cardArts.length})</h4>
        <CardArtRow cardArts={cardArts}/>
      </div>
  );
};

export default ExtraDeck;
