var localStorage = global.localStorage

var subscribersByRoomId = {}

module.exports = {
  getRoom: function (roomId) {
    return Promise.resolve(JSON.parse(localStorage.getItem('/rooms/' + roomId)))
  },
  setRoom: function (room) {
    localStorage.setItem('/rooms/' + room.id, JSON.stringify(room))
    return Promise.resolve()
  },
  subscribeToRoom: function (roomId, onValue) {
    var previousValue
    subscribersByRoomId[roomId] = {
      onValue: onValue,
      interval: global.setInterval(function () {
        var value = localStorage.getItem('/rooms/' + roomId)
        if (previousValue !== value) {
          onValue(JSON.parse(value))
        }
        previousValue = value
      }, 100)
    }
  },
  unsubscribeFromRoom: function (roomId) {
    global.clearInterval(subscribersByRoomId[roomId].interval)
    subscribersByRoomId[roomId] = null
  }
}
