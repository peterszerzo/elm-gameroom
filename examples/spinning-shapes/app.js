// Stores room state, peer clients and connections by room id
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory()
  } else {
    root.db = factory()
  }
}(this, function () {
  var peerOptions = {
    key: 'lwjd5qra8257b9'
  }

  var log = console.log.bind(console)

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

  var db = function () {
    var rooms = {}

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

    var connectToHost = memoize(function (roomId) {
      return loadPeerJs().then(function (Peer) {
        return new Promise(function (resolve, reject) {
          var room = rooms[roomId]
          var peer
          if (room && room.peer) {
            peer = room.peer
          } else {
            peer = new Peer('elm-gameroom-' + roomId + '-' + new Date().getTime(), peerOptions)
            peer.on('error', log)
          }
          var connection
          if (room && room.connectionToHost) {
            connection = room.connectionToHost
          } else {
            connection = peer.connect('elm-gameroom-' + roomId)
            connection.on('error', log)
          }
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

    function isHost (roomId) {
      return rooms[roomId] && rooms[roomId].isHost
    }

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
            .catch(log)
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
                  connection.send({
                    type: 'room:updated',
                    payload: rooms[room.id].state
                  })
                  rooms[room.id].subscribers.push(connection)
                  return
                case 'unsubscribefrom:room':
                  // This need not be handled, as closed connections are removed automatically
                  return
                case 'update:room':
                  rooms[room.id].state = msg.payload
                  updateSubscribers(room.id)
                  return
                case 'update:player':
                  rooms[room.id].state.players[msg.payload.id] = msg.payload
                  updateSubscribers(room.id)
                  return
              }
            })
          })
        })
        .catch(log)
      },

      subscribeToRoom: function (roomId, onValue) {
        if (isHost(roomId)) {
          rooms[roomId].ownSubscribers.push(onValue)
          onValue(rooms[roomId].state)
        } else {
          return connectToHost(roomId).then(function (connection) {
            connection.on('data', function (msg) {
              if (msg.type === 'room:updated') {
                onValue(msg.payload)
              }
            })
            connection.send({
              type: 'subscribeto:room',
              payload: roomId
            })
          })
        }
      },

      unsubscribeFromRoom: function (roomId) {
        if (isHost(roomId)) {
          rooms[roomId].ownSubscribers = []
        } else {
          // TODO: handle this case
          return
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
          .catch(log)
        }
      },

      updatePlayer: function (player) {
        if (isHost(player.roomId)) {
          rooms[player.roomId].state.players[player.id] = player
          updateSubscribers(player.roomId)
          return Promise.resolve(player)
        } else {
          return connectToHost(player.roomId).then(function (connection) {
            connection.send({
              type: 'update:player',
              payload: player
            })
            return connection
          })
          .then(function (connection) {
            return player
          })
          .catch(log)
        }
      }
    }
  }

  return db
}))
/**
 * This function handles communication between the Elm ports and the datastore.
 * @param {object} db - datastore API
 * @param {object} ports - Elm ports
 * @return {object} ports
 */
var talkToPorts = function (db, ports) {
  ports.outgoing.subscribe(function (msg) {
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
        return db.createRoom(payload).then(function () {
          ports.incoming.send(JSON.stringify({
            type: 'room:created',
            payload: payload
          }))
        })
      // Update room. If subscribed, this should signal back to the roomUpdated port.
      // Hence, no feedback is necessary in this method.
      case 'update:room':
        return db.updateRoom(payload)
      case 'update:player':
        return db.updatePlayer(payload)
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
