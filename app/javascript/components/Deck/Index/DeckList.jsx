import React from "react";
import DeckListItem from "./DeckListItem";

const DeckList = ({decks}) => {
  return (
      <ul className="list-group decks">
        {decks.map((deck) => <DeckListItem key={deck.id} deck={deck}/>)}
      </ul>
  );
};

export default DeckList;
