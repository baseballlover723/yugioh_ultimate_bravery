import React, {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import DeckList from "./DeckList";

const DeckIndex = () => {
  const navigate = useNavigate();
  const [decks, setDecks] = useState([]);

  useEffect(() => {
    const path = "/api/v1/deck";
    fetch(path).then((res) => {
      if (res.ok) {
        return res.json();
      }
      throw new Error(`Error fetching decks from api (${path} => ${res.status} ${res.statusText})`);
    }).then((data) => {
      setDecks(data);
    }).catch((e) => {
      console.error(e);
      return navigate("/");
    });
  }, []);

  return (
      <>
        <div>Decks</div>
        <DeckList decks={decks}/>
      </>
  );
};

export default DeckIndex;
// export default () => (
//     <div className="vw-100 vh-100 primary-color d-flex align-items-center justify-content-center">
//       <div className="jumbotron jumbotron-fluid bg-transparent">
//         <div className="container secondary-color">
//           <h1 className="display-4">Food Recipes</h1>
//           <p className="lead">
//             A curated list of recipes for the best homemade meal and delicacies.
//           </p>
//           <hr className="my-4"/>
//           <Link
//               to="/recipes"
//               className="btn btn-lg custom-button"
//               role="button"
//           >
//             View Recipes
//           </Link>
//         </div>
//       </div>
//     </div>
// );
