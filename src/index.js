require('./main.css');
var Elm = require('./Main.elm');
var db = require('./db');

var app = Elm.Main.embed(document.getElementById('root'));

function talkToGame(ports) {
  var log = console.log.bind(console);
  ports.connectToRoom.subscribe(function(roomId) {
    db.getRoom(roomId).then(function(room) {
      ports.roomUpdated.send(JSON.stringify(room));
    });
  });
}

talkToGame(app.ports);
