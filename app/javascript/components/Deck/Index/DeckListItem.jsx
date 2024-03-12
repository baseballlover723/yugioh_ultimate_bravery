import React from "react";
import {Link} from "react-router-dom";

const DeckListItem = ({deck}) => {
  const numbCards = deck.mainDeckCardArts.length;
  const numbSpells = deck.mainDeckCardArts.filter((cardArt) => cardArt.card.frameType === "spell").length;
  const numbTraps = deck.mainDeckCardArts.filter((cardArt) => cardArt.card.frameType === "trap").length;
  const numbMonsters = numbCards - numbSpells - numbTraps;
  const numbExtra = deck.extraDeckCardArts.length;

  return (
      <li className="list-group-item">
        <Link to={`/deck/${deck.id}`} target="_blank" rel="noopener noreferrer">
          {deck.name} ({numbMonsters} Monsters, {numbSpells} Spells, {numbTraps} Traps): {numbCards} Cards. {numbExtra} Extra Deck Cards
        </Link>
      </li>
  );
};

export default DeckListItem;
