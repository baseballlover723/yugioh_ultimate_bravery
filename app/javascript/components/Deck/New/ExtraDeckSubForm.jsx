import React from "react";
import RangeInput from "./RangeInput";

const ExtraDeckSubForm = ({getFormData, updateFormData, parentPaths}) => {
  const paths = [...parentPaths, "extraDeck"];

  return (
      <div>
        Extra Deck Sub Form
        <RangeInput fieldName="countCamel" humanFieldName="Number of Extra Deck Monsters" getFormData={getFormData}
                    updateFormData={updateFormData} parentPaths={paths}/>
        {/*{[...Array(10)].map((_, i) => {*/}
        {/*  const pathss = [...paths, "extra", "another", i.toString()];*/}
        {/*  return <RangeInput key={i} fieldName={`count${i}`} humanFieldName="Extra Test" getFormData={getFormData}*/}
        {/*                     updateFormData={updateFormData} parentPaths={pathss}/>*/}
        {/*})}*/}
        <RangeInput fieldName="countCamel2" humanFieldName="Extra Test" getFormData={getFormData}
                    updateFormData={updateFormData} parentPaths={[...paths, "extra", "another", "one"]}/>
      </div>
  );
};

export default ExtraDeckSubForm;
