module.exports = function (db, ports) {
  ports.subscribeToRoom.subscribe(function (roomId) {
    db.subscribeToRoom(roomId, function (room) {
      ports.roomUpdated.send(JSON.stringify(room))
    })
  })
  ports.createRoom.subscribe(function (room) {
    db.setRoom(JSON.parse(room))
  })
}
