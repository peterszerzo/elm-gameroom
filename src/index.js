require('./main.css');
var Elm = require('./Main.elm');
require('./db');

var app = Elm.Main.embed(document.getElementById('root'));

function talkToGame(ports) {
  var log = console.log.bind(console);
  ports.update.subscribe(log);
  ports.create.subscribe(log);
  ports.disconnect.subscribe(log);
  ports.reconnect.subscribe(log);
}

talkToGame(app.ports);
