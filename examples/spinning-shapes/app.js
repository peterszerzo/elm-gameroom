/**
 * Simple local db, polling localStorage
 *
 */

var db = function () {
  var localStorage = window.localStorage

  var _subscribersByRoomId = {}

  return {
    getRoom: function (roomId) {
      return Promise.resolve(JSON.parse(localStorage.getItem('/rooms/' + roomId)))
    },

    setRoom: function (room) {
      localStorage.setItem('/rooms/' + room.id, JSON.stringify(room))
      return Promise.resolve(room)
    },

    setPlayer: function (player) {
      var room = JSON.parse(localStorage.getItem('/rooms/' + player.roomId))
      room.players[player.id] = player
      localStorage.setItem('/rooms/' + player.roomId, JSON.stringify(room))
      return Promise.resolve(player)
    },

    subscribeToRoom: function (roomId, onValue) {
      var previousValue
      _subscribersByRoomId[roomId] = {
        onValue: onValue,
        interval: window.setInterval(function () {
          var value = localStorage.getItem('/rooms/' + roomId)
          if (previousValue !== value) {
            onValue(JSON.parse(value))
          }
          previousValue = value
        }, 100)
      }
      return onValue
    },

    unsubscribeFromRoom: function (roomId) {
      window.clearInterval(_subscribersByRoomId[roomId].interval)
      _subscribersByRoomId[roomId] = null
    }
  }
}

if (typeof module === 'object' && module.exports) {
  module.exports = db
} else {
  window.db = db
}
/**
 * This function handles communication between the Elm ports and the datastore.
 * @param {object} db - datastore API
 * @param {object} ports - Elm ports
 * @return {object} ports
 */
var talkToPorts = function (db, ports) {
  ports.outgoing.subscribe(function (msg) {
    console.log(msg)
    var data = JSON.parse(msg)
    var type = data.type
    var payload = data.payload
    switch (type) {
      // Subscribe to room, sending room:updated messages
      case 'subscribeto:room':
        return db.subscribeToRoom(payload, function (room) {
          ports.incoming.send(JSON.stringify({
            type: 'room:updated',
            payload: room
          }))
        })
      // Unsubscribe from room, making sure room:updated messages are no longer sent
      case 'unsubscribefrom:room':
        return db.unsubscribeFromRoom(payload)
      // Create new game room in storage, sending back a room:created message.
      case 'create:room':
        return db.setRoom(payload).then(function () {
          ports.incoming.send(JSON.stringify({
            type: 'room:created',
            payload: payload
          }))
        })
      // Update room. If subscribed, this should signal back to the roomUpdated port.
      // Hence, no feedback is necessary in this method.
      case 'update:room':
        return db.setRoom(payload)
      case 'update:player':
        return db.setPlayer(payload)
      default:
        return
    }
  })

  return ports
}

if (typeof module === 'object' && module.exports) {
  module.exports = talkToPorts
} else {
  window.talkToPorts = talkToPorts
}
