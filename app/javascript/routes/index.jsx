import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "../components/Layout";
import DevHome from "../components/DevHome";
import DeckShow from "../components/Deck/Show/DeckShow";
import DeckNew from "../components/Deck/New/DeckNew";

export default (
    <Router>
      <Routes>
        <Route path="/" element={<Layout><DeckNew/></Layout>} />
        <Route path="/devHome" element={<Layout><DevHome/></Layout>} />
        <Route path="/deck/:id" element={<Layout><DeckShow/></Layout>} />
      </Routes>
    </Router>
);
