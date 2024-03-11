import React from "react";
import CardArt from "./CardArt";

const SkillCardArt = ({cardArt}) => {
  return (
      <div className="skill-card-art">
        <h4>Skill Card</h4>
        <CardArt cardArt={cardArt}/>
      </div>
  );
};

export default SkillCardArt;
