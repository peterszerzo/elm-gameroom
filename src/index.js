var Elm = require('./Main.elm')
var db = require('./db')
var gameroom = require('./gameroom')

var app = Elm.Main.embed(document.getElementById('root'))
gameroom(db, app.ports)
