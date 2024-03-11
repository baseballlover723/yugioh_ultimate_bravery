import React from "react";
import Header from "././Header/Header";
import Footer from "././Footer/Footer";

export default (props) => (
    <>
      <div className="vw-100 vh-100 primary-color d-flex flex-column">
      <Header />
        <div className="container secondary-color">
          Children underneath
          {props.children}
        </div>
      <Footer />
      </div>
    </>
);
