import { Elm } from './src/Main.elm';
import './assets/stylesheets/main.scss';



// CONFIG


var httpConfig = {
    baseUrl: null,
    apiKey: null
};



// MAIN

var app = Elm.Main.init({
  node: document.getElementById('redmine'),
  flags: {
      http: httpConfig
  }
});
