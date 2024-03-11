import React from "react";
import {Link} from "react-router-dom";

const DeckListItem = ({deck}) => {
  return (


      <li className="list-group-item">
        <Link to={`/deck/${deck.id}`} target="_blank" rel="noopener noreferrer">
          {deck.name}
        </Link>
      </li>
  );
};

export default DeckListItem;
