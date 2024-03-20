import React, {useRef} from "react";
import {useNavigate} from "react-router-dom";
import {bury, dig, jsonSetReplacer, resolveActive, snakifyKeys} from "../../../Utils";
import Submit from "./Submit";
import ExtraDeckSubForm from "./ExtraDeckSubForm";

const DeckNew = () => {
  const navigate = useNavigate();
  const formData = useRef({});

  const updateFormData = (paths, value) => {
    // console.log(`got change for `, paths, value);
    bury(formData.current, paths, value);
  };

  const getFormData = (paths) => {
    // console.log("getting formData for ", paths);
    return dig(formData.current, paths);
  }

  const onSubmit = (event) => {
    event.preventDefault();
    const path = "/api/v1/deck";
    // console.log("sending formData: ", formData);

    const nestedFormData = resolveActive(snakifyKeys(formData.current));
    console.log("nestedFormData", nestedFormData);

    const token = document.querySelector('meta[name="csrf-token"]').content;
    const options = {
      method: "POST",
      headers: {"X-CSRF-Token": token, "Content-Type": "application/json"},
      body: JSON.stringify(nestedFormData, jsonSetReplacer)
    };
    fetch(path, options).then((res) => {
      if (res.ok) {
        return res.json();
      }
      throw new Error(`Error generating new deck from api (${path} => ${res.status} ${res.statusText})`);
    }).then((data) => {
      console.log("got data back: ", data);
    }).catch((e) => {
      console.error(e);
      return navigate("/");
    });
  };

  return (
      <>
        <div>
          Deck New
          <form onSubmit={onSubmit}>
            <ExtraDeckSubForm getFormData={getFormData} updateFormData={updateFormData} parentPaths={[]}/>
            <Submit/>
          </form>
          <div>
            Form data: {JSON.stringify(formData, jsonSetReplacer)}
          </div>
        </div>
        {/*<div className="deck">*/}
        {/*  <h2>{deck.name}</h2>*/}
        {/*  <div>format: {deck.format}</div>*/}
        {/*  <div>generateOptions: {JSON.stringify(deck.generateOptions)}</div>*/}
        {/*  {deck.skillCardArt && <SkillCardArt cardArt={deck.skillCardArt}/>}*/}
        {/*  <MainDeck cardArts={deck.mainDeckCardArts}/>*/}
        {/*  <ExtraDeck cardArts={deck.extraDeckCardArts}/>*/}
        {/*</div>*/}
        {/*Deck: {JSON.stringify(deck)}*/}
      </>
  );
};

export default DeckNew;
