/**
 * This function handles communication between the Elm ports and the datastore.
 * @param {object} db - datastore API
 * @param {object} ports - Elm ports
 * @return {object} ports
 */
module.exports = function (db, ports) {
  // Subscribe to room, sending updates to the roomUpdated port
  ports.subscribeToRoom.subscribe(function (roomId) {
    db.subscribeToRoom(roomId, function (room) {
      ports.roomUpdated.send(JSON.stringify(room))
    })
  })

  // Unsubscribe from room, making sure port roomUpdated doesn't get any new values
  ports.unsubscribeFromRoom.subscribe(function (roomId) {
    db.unsubscribeFromRoom(roomId)
  })

  // Create new game room in storage, sending it back to the roomCreated port.
  ports.createRoom.subscribe(function (room) {
    db.setRoom(JSON.parse(room)).then(function () {
      ports.roomCreated.send(room)
    })
  })

  // Update room. If subscribed, this should signal back to the roomUpdated port.
  // Hence, no feedback is necessary in this method.
  ports.updateRoom.subscribe(function (room) {
    db.setRoom(JSON.parse(room))
  })

  return ports
}
