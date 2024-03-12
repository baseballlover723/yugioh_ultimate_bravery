import {camelCase} from 'lodash';
import cardArt from "./components/Deck/CardArt";

export const camelizeKeys = (obj) => {
  if (Array.isArray(obj)) {
    return obj.map(v => camelizeKeys(v));
  } else if (obj != null && obj.constructor === Object) {
    return Object.keys(obj).reduce(
        (result, key) => ({
          ...result,
          [camelCase(key)]: camelizeKeys(obj[key]),
        }),
        {},
    );
  }
  return obj;
};

export const partition = (arr, fn) =>
    arr.reduce(
        (acc, val, i, arr) => {
          acc[fn(val, i, arr) ? 0 : 1].push(val);
          return acc;
        },
        [[], []]
    );

const MAIN_DECK_FRAME_TYPES_SORT = {
  normal: 1,
  normal_pendulum: 2,
  effect: 3,
  effect_pendulum: 4,
  ritual: 5,
  ritual_pendulum: 6,
  spell: 7,
  trap: 8
}
const MAIN_DECK_RACES_SORT = {
  spell: {Normal: 1, Ritual: 2, Equip: 3, Continuous: 4, Field: 5, "Quick-Play": 6},
  trap: {Normal: 1, Continuous: 2, Counter: 3}
};
export const sortMainDeck = (arr) => {
  multiSort(arr, (cardArt) => MAIN_DECK_FRAME_TYPES_SORT[cardArt.card.frameType], (cardArt) => cardArt.card.level, (cardArt) => cardArt.card.atk, (cardArt) => cardArt.card.def, (cardArt) => MAIN_DECK_RACES_SORT[cardArt.card.frameType]?.[cardArt.card.race], (cardArt) => cardArt.card.name);
}

const EXTRA_DECK_FRAME_TYPES_SORT = {
  fusion: 1,
  fusion_pendulum: 1,
  synchro: 2,
  synchro_pendulum: 2,
  xyz: 3,
  xyz_pendulum: 3,
  link: 4
};
export const sortExtraDeck = (arr) => {
  multiSort(arr, (cardArt) => EXTRA_DECK_FRAME_TYPES_SORT[cardArt.card.frameType], (cardArt) => cardArt.card.level, (cardArt) => cardArt.card.atk, (cardArt) => cardArt.card.def, (cardArt) => cardArt.card.name);
}

function multiSort(arr, ...funcs) {
  arr.sort((a, b) => {
    return multiCompare(a, b, funcs)
  })
}

function multiCompare(a, b, funcs) {
  for (const func of funcs) {
    const result = func(a) - func(b);
    if (result) {
      return result;
    }
  }
}
