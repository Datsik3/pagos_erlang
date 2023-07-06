"use strict";
var lista = [];

document.querySelector("#btn_login").addEventListener("click", (event) => {
  const data = {
    username: document.querySelector("#username").value,
    password: document.querySelector("#password").value,
  };
  fetch("/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  })
    .then((response) => response.json())
    .then((data) => {
      console.log(data);
      if (localStorage.getItem("productos") !== null) {
        
        lista = JSON.parse(localStorage.getItem("productos"));
      } else {
        lista = [];
      }
      lista.push(data);
      localStorage.setItem("productos", JSON.stringify(lista));
      
      window.location.href = "/home";
    })
    .catch((error) => alert("Caught Exception: " + error.description));
});
