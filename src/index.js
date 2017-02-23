var Elm = require('./Main.elm')
var db = require('./db/local')
var gameroom = require('./gameroom')

var app = Elm.Main.embed(document.getElementById('root'))
gameroom(db, app.ports)
