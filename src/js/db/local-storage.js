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
