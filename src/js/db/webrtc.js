// Stores room state, peer clients and connections by room id
var rooms = {}

function isHost (roomId) {
  return rooms[roomId] && rooms[roomId].isHost
}

var peerOptions = {
  key: 'lwjd5qra8257b9'
}

var hasOwnProperty = Object.prototype.hasOwnProperty;

function extend() {
  var target = {}
  for (var i = 0; i < arguments.length; i++) {
    var source = arguments[i]
    for (var key in source) {
      if (Object.prototype.hasOwnProperty.call(source, key)) {
        target[key] = source[key]
      }
    }
  }
  return target
}

function memoize (fn) {
  return function () {
    var args = Array.prototype.slice.call(arguments)
    var hash = args.reduce(function (acc, current) {
      return acc + ((current === Object(current)) ? JSON.stringify(current) : current)
    }, '')
    fn.memo = fn.memo || {}
    if (fn.memo[hash]) {
      return fn.memo[hash]
    }
    var returnValue = fn.apply(this, args)
    fn.memo[hash] = returnValue
    return returnValue
  }
}

var loadPeerJs = memoize(function loadPeerJs () {
  var url = 'http://cdn.peerjs.com/0.3/peer.js'
  return new Promise(function (resolve, reject) {
    var scriptTag = document.createElement('script')
    scriptTag.src = url
    scriptTag.onload = function () {
      resolve(window.Peer)
    }
    document.body.appendChild(scriptTag)
  })
})

var connectToHost = memoize(function (roomId) {
  return loadPeerJs().then(function (Peer) {
    return new Promise(function (resolve, reject) {
      var room = rooms[roomId]
      var peer = (room && room.peer) || new Peer('elm-gameroom-' + new Date().getTime(), peerOptions)
      var connection =
        (room && room.connectionToHost)
        ? room.connectionToHost
        : peer.connect('elm-gameroom-' + roomId)
      rooms[roomId] = {
        peer: peer,
        connectionToHost: connection,
        isHost: false
      }
      connection.on('open', function () {
        resolve(connection)
      })
    })
  })
})

function updateSubscribers (roomId) {
  if (!isHost(roomId)) {
    return
  }
  rooms[roomId].subscribers.forEach(function (connection) {
    connection.send({
      type: 'room:updated',
      payload: rooms[roomId].state
    })
  })
  rooms[roomId].ownSubscribers.forEach(function (subscriber) {
    subscriber(rooms[roomId].state)
  })
}

var db = function () {
  return {
    getRoom: function (roomId) {
      if (isHost(roomId)) {
        return Promise.resolve(rooms[roomId].state)
      } else {
        return loadPeerJs().then(function (Peer) {
          return connectToHost(roomId).then(function (connection) {
            return new Promise(function (resolve, reject) {
              var onData = function (data) {
                resolve(data)
              }
              connection.on('data', onData)
              connection.send({
                type: 'get:room',
                payload: {
                  roomId: roomId
                }
              })
            })
          })
          .catch(console.log.bind(console))
        })
      }
    },

    createRoom: function (room) {
      return loadPeerJs().then(function (Peer) {
        var peer = new Peer('elm-gameroom-' + room.id, peerOptions)
        rooms[room.id] = {
          peer: peer,
          isHost: true,
          connectionToHost: null,
          state: room,
          subscribers: [],
          ownSubscribers: []
        }
        peer.on('connection', function (connection) {
          connection.on('data', function (msg) {
            switch (msg.type) {
              // Subscribe to room, sending room:updated messages
              case 'get:room':
                return connection.send(rooms[room.id].state)
              case 'subscribeto:room':
                connection.send(rooms[room.id].state)
                rooms[room.id].subscribers =
                  rooms[room.id].subscribers.concat([connection])
                return
              case 'unsubscribefrom:room':
                // This need not be handled, as closed connections are removed automatically
                return
              case 'update:room':
                rooms[room.id].state = msg.payload
                updateSubscribers(room.id)
                return
              case 'update:player':
                rooms[room.id].state.players[player.id] = msg.payload
                updateSubscribers(room.id)
                return
            }
          })
        })
      })
      .catch(console.log.bind(console))
    },

    subscribeToRoom: function (roomId, onValue) {
      if (isHost(roomId)) {
        rooms[roomId].ownSubscribers.push(onValue)
        onValue(rooms[roomId].state)
      } else {
        return connectToHost(roomId).then(function (connection) {
          connection.send({
            type: 'subscribeto:room',
            payload: roomId
          })
        })
      }
    },

    updateRoom: function (room) {
      if (isHost(room.id)) {
        rooms[room.id].state = room
        updateSubscribers(room.id)
        return Promise.resolve(room)
      } else {
        return connectToHost(room.id).then(function (connection) {
          connection.send({
            type: 'update:room',
            payload: room
          })
          return connection
        })
        .then(function (connection) {
          return room
        })
        .catch(console.log.bind(console))
      }
    },

    updatePlayer: function (player) {
      if (isHost(player.roomId)) {
        rooms[room.id].state.players[player.id] = player
        updateSubscribers(room.id)
        return Promise.resolve(room)
      } else {
        return connectToHost(room.id).then(function (connection) {
          connection.send({
            type: 'update:player',
            payload: player
          })
          return connection
        })
        .then(function (connection) {
          return room
        })
        .catch(console.log.bind(console))
      }
    }
  }
}

if (typeof module === 'object' && module.exports) {
  module.exports = db
} else {
  window.db = db
}
