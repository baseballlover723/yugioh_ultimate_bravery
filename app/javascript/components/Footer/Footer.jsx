import React from "react";

const Footer = () => {
  return (
      <>
        <footer className="py-2 my-4 border-top bg-body-tertiary">
          <div className="container d-flex flex-wrap justify-content-between align-items-center">
            <div className="col-md-4 d-flex align-items-center">
              <span>Created by <a href="https://github.com/baseballlover723" target="_blank"
                                  rel="noopener noreferrer">baseballlover723</a></span>
            </div>
            <ul className="nav col-md-4 justify-content-end list-unstyled d-flex align-items-center">
              <li className="ms-3">
                <a href="mailto:yugioh_ultimate_bravery@baseballlover723.com">
                  <i className="bi bi-envelope fs-2"></i>
                </a>
              </li>
              <li className="ms-3">
                <a href="https://github.com/baseballlover723/yugioh_ultimate_bravery" target="_blank"
                   rel="noopener noreferrer">
                  <i className="bi bi-github fs-2" role="img" aria-label="Github"></i>
                </a>
              </li>
            </ul>
          </div>
        </footer>
      </>
  );
};

export default Footer;
