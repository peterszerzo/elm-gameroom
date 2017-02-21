var Elm = require('./Main.elm')
var db = require('./db')

var app = Elm.Main.embed(document.getElementById('root'))

function talkToGame (ports) {
  ports.connectToRoom.subscribe(function (roomId) {
    db.subscribeToRoom(roomId, function (room) {
      ports.roomUpdated.send(JSON.stringify(room))
    })
  })
  ports.createRoom.subscribe(function (room) {
    db.updateRoom(JSON.parse(room))
  })
}

talkToGame(app.ports)
