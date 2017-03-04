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
   * @param {string} stringified room object.
   * @return {Promise}
   */
  setRoom: function (room) {
    localStorage.setItem('/rooms/' + room.id, JSON.stringify(room))
    return Promise.resolve(room)
  },

  /**
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
