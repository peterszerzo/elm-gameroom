var localStorage = window.localStorage

var __subscribersByRoomId = {}

window.db = {
  getRoom: function (roomId) {
    return Promise.resolve(JSON.parse(localStorage.getItem('/rooms/' + roomId)))
  },
  setRoom: function (room) {
    localStorage.setItem('/rooms/' + room.id, JSON.stringify(room))
    return Promise.resolve(room)
  },
  subscribeToRoom: function (roomId, onValue) {
    var previousValue
    __subscribersByRoomId[roomId] = {
      onValue: onValue,
      interval: window.setInterval(function () {
        var value = localStorage.getItem('/rooms/' + roomId)
        if (previousValue !== value) {
          onValue(JSON.parse(value))
        }
        previousValue = value
      }, 1000)
    }
  },
  unsubscribeFromRoom: function (roomId) {
    window.clearInterval(__subscribersByRoomId[roomId].interval)
    __subscribersByRoomId[roomId] = null
  }
}
