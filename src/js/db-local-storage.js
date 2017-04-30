/**
 * Simple local db, polling localStorage
 *
 */

var localStorage = window.localStorage

var _subscribersByRoomId = {}

module.exports = {
  /**
   * @param {string} roomId - Room id.
   * @return {Promise}
   */
  getRoom: function (roomId) {
    return Promise.resolve(JSON.parse(localStorage.getItem('/rooms/' + roomId)))
  },

  /**
   * Set room in local storage.
   * @param {Object} room - Room object.
   * @return {Promise} promise - Resolves in the room object.
   */
  setRoom: function (room) {
    localStorage.setItem('/rooms/' + room.id, JSON.stringify(room))
    return Promise.resolve(room)
  },

  /**
   * Set player in local storage.
   * @param {Object} player - Player object.
   * @return {Promise} promise - Resolves in the player.
   */
  setPlayer: function (player) {
    var room = JSON.parse(localStorage.getItem('/rooms/' + player.roomId))
    room.players[player.id] = player
    localStorage.setItem('/rooms/' + player.roomId, JSON.stringify(room))
    return Promise.resolve(player)
  },

  /**
   * Subscribe to a room.
   * @param {string} roomId - Room id.
   * @param {function} onValue - Update callback.
   * @return {function} onValue
   */
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
      }, 1000)
    }
    return onValue
  },

  /**
   * @param {string} roomId - Room id.
   */
  unsubscribeFromRoom: function (roomId) {
    window.clearInterval(_subscribersByRoomId[roomId].interval)
    _subscribersByRoomId[roomId] = null
  }
}
