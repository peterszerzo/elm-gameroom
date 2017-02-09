require('./main.css');
var Elm = require('./Main.elm');
var db = require('./db');

var app = Elm.Main.embed(document.getElementById('root'));

function talkToGame(ports) {
  var log = console.log.bind(console);
  ports.update.subscribe(log);
  ports.create.subscribe(log);
  ports.disconnect.subscribe(log);
  ports.reconnect.subscribe(log);
  db.getRoom('theroom').then(function(room) {
    ports.updated.send(JSON.stringify(room));
  });
}

talkToGame(app.ports);
