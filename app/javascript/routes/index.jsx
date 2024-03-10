import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "../components/Layout";
import DevHome from "../components/DevHome";

export default (
    <Router>
      <Routes>
        <Route path="/" element={<Layout><DevHome/></Layout>} />
      </Routes>
    </Router>
);
