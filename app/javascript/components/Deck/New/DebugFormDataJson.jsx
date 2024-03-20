import React, {forwardRef, useImperativeHandle, useReducer} from "react";
import {jsonSetReplacer} from "../../../Utils";

const DebugFormDataJson = forwardRef(({formData}, ref) => {
  const [, forceUpdate] = useReducer(x => x + 1, 0);

  useImperativeHandle(ref, () => ({
    forceRender() {
      forceUpdate();
    }
  }));

  return (
      <div>
        Form data: {JSON.stringify(formData.current, jsonSetReplacer)}
      </div>
  );
});

export default DebugFormDataJson;
