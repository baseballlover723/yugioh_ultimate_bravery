import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "../components/Layout";
import DevHome from "../components/DevHome";
import DeckShow from "../components/./Deck/./Show/DeckShow";

export default (
    <Router>
      <Routes>
        <Route path="/" element={<Layout><DevHome/></Layout>} />
        <Route path="/deck/:id" element={<Layout><DeckShow/></Layout>} />
      </Routes>
    </Router>
);
