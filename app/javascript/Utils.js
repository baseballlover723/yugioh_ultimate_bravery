import {camelCase} from 'lodash';

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
