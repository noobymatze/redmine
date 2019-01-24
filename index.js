import { Elm } from './src/Main.elm';
import './assets/stylesheets/main.scss';





// MAIN

var maybeSession = localStorage.getItem('session');
var app = Elm.Main.init({
  node: document.getElementById('redmine'),
  flags: {
      session: maybeSession
  }
});



// PORTS


app.ports.outgoing.subscribe(function (message) {
    switch(message.type) {
        case 'Authenticated':
            localStorage.setItem('session', JSON.stringify(message.session));
            break;
    }
})


