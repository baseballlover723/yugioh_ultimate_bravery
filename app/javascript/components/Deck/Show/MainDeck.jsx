import React from "react";
import CardArtRow from "../CardArtRow";

const MainDeck = ({cardArts}) => {
  return (
      <div className="main-deck">
        <h4>Main Deck ({cardArts.length})</h4>
        <CardArtRow cardArts={cardArts}/>
      </div>
  );
};

export default MainDeck;
