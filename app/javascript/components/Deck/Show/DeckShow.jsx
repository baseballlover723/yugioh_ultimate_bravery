import React, {useEffect, useState} from "react";
import {useNavigate, useParams} from "react-router-dom";
import SkillCardArt from "../SkillCardArt";
import MainDeck from "./MainDeck";
import ExtraDeck from "./ExtraDeck";
import {camelizeKeys, partition} from "../../../Utils";

const DeckShow = () => {
  const params = useParams();
  const navigate = useNavigate();
  const [deck, setDeck] = useState({
    id: "",
    name: "",
    format: null,
    skillCardArt: null,
    generateOptions: {},
    createdAt: null,
    updatedAt: null,
    cardArts: []
  });

  useEffect(() => {
    const path = `/api/v1/deck/${params.id}`;
    fetch(path).then((res) => {
      if (res.ok) {
        return res.json();
      }
      throw new Error(`Error fetching decks from api (${path} => ${res.status} ${res.statusText})`);
    }).then((data) => {
      setDeck(camelizeKeys(data));
    }).catch((e) => {
      console.error(e);
      return navigate("/");
    });
  }, []);

  const [extraDeckCards, mainDeckCards] = partition(deck.cardArts, cardArt => cardArt.card.extraDeck);

  return (
      <>
        <div className="deck">
          <h2>{deck.name}</h2>
          <div>format: {deck.format}</div>
          <div>generateOptions: {JSON.stringify(deck.generateOptions)}</div>
          {deck.skillCardArt && <SkillCardArt cardArt={deck.skillCardArt}/>}
          <MainDeck cardArts={mainDeckCards}/>
          <ExtraDeck cardArts={extraDeckCards}/>
        </div>
        Deck: {JSON.stringify(deck)}
      </>
  );
};

export default DeckShow;
