import React, {useState} from "react";
import Slider from 'rc-slider';
import Switch from "rc-switch";
import {createRange, toggleSetValue} from "../../../Utils";

const RangeInput = ({fieldName, humanFieldName, getFormData, updateFormData, parentPaths, min = 3, max = 15}) => {
  const paths = [...parentPaths, fieldName];
  const sliderDefaultValues = [getFormData(paths)?.min || min, getFormData(paths)?.max || max]
  const [useEnumForm, setUseEnumForm] = useState(false);
  const [enumFormData, setEnumFormData] = useState(getFormData(paths)?.enum || new Set(createRange(sliderDefaultValues[0], sliderDefaultValues[1]))); // TODO update back to grabbing from form data

  const onSwitchChange = (value, event) => {
    setUseEnumForm(value);
    updateFormData(paths, {active: value ? "enum" : "range"});
  }

  const onEnumChange = (i, checked) => {
    const newSet = toggleSetValue(enumFormData, i);
    setEnumFormData(newSet);
    onRangeChange("enum", newSet);
  }

  const onRangeChange = (branchName, value) => {
    const persistedData = {active: branchName};

    switch (branchName) {
      case "exact":
        persistedData[branchName] = value;
        break;
      case "range":
        persistedData.min = value[0];
        persistedData.max = value[1];
        break;
      case "enum":
        persistedData.enum = value;
        break
    }
    updateFormData(paths, persistedData);
  }

  const marks = createRange(min, max).reduce((acc, i) => (acc[i] = i, acc), {});
  // const checkboxes = Array.from({length: max - min + 1}, (_, i) => min + i).map((i) => {
  //   return <input key={i} className="rc-slider-dot form-check-input" type="checkbox"/>;
  // });
  // const checkboxesMarks = Array.from({length: max - min + 1}, (_, i) => min + i).map((i) => {
  //   return <span key={i} className="rc-slider-mark-text">{i}</span>;
  // });

  const slider = <Slider range defaultValue={sliderDefaultValues} min={min} max={max} marks={marks}
                         allowCross={true} pushable={0} onChange={(value) => onRangeChange("range", value)}
  />;
  const checkboxes = <div className="checkboxes">
    {Array.from({length: max - min + 1}, (_, i) => min + i).map((i) =>
        <span key={i} className="checkbox">
        <input className="form-check-input" type="checkbox" defaultChecked={enumFormData.has(i)}
               onChange={(e) => onEnumChange(i, e.target.checked)}/>
          <span className="checkbox-label">{i}</span>
      </span>)}
  </div>;

  return (
      <div className="range-input">
        <label htmlFor={`${fieldName}`}>{humanFieldName}:&nbsp;</label>
        <Switch className="array-toggler" onChange={onSwitchChange}/> Switch
        to {useEnumForm ? "Range" : "Specific Values"}
        {useEnumForm ? checkboxes : slider}
      </div>
  );
};

export default RangeInput;
