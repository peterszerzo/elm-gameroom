require('./main.css');
var Elm = require('./Main.elm');

var app = Elm.Main.embed(document.getElementById('root'));

function talkToGame(gamePorts) {
  var log = console.log.bind(console);
  ports.update.subscribe(log);
  ports.create.subscribe(log);
  ports.disconnect.subscribe(log);
  ports.connect.subscribe(log);
}

talkToGame(app.ports);
