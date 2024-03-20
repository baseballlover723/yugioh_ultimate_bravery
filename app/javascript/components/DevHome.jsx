import React from "react";
import {Link} from "react-router-dom";
import DeckIndex from "././Deck/./Index/DeckIndex";

export default () => (
    <>
      <div>Dev Home</div>
      <Link to="/">
        Create New Deck
      </Link>
      <DeckIndex/>
    </>
);
