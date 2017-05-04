var peerClientsByRoomId = {}

function isHost (roomId) {
  return peerClientsByRoomId[roomId] && peerClientsByRoomId[roomId].isHost
}

var peerOptions = {
  key: 'lwjd5qra8257b9'
}

var peerJsloadPromise

function loadPeerJs () {
  if (peerJsloadPromise) {
    return peerJsloadPromise
  }
  var url = 'http://cdn.peerjs.com/0.3/peer.min.js'
  peerJsloadPromise = new Promise(function (resolve, reject) {
    var scriptTag = document.createElement('script')
    scriptTag.src = url
    scriptTag.onload = function () {
      resolve(window.Peer)
    }
    document.body.appendChild(scriptTag)
  })
  return peerJsloadPromise
}

var db = function () {
  return {
    getRoom: function (roomId) {
      if (isHost(roomId)) {
        return Promise.resolve(JSON.parse(localStorage.getItem('/rooms/' + roomId)))
      } else {
        return loadPeerJs().then(function (Peer) {
          return new Promise(function (resolve, reject) {
            var peer = (peerClientsByRoomId[roomId] && peerClientsByRoomId[roomId].peer) || new Peer('elm-gameroom-' + new Date().getTime(), peerOptions)
            var conn = peer.connect('elm-gameroom-' + roomId)
            conn.on('open', function () {
              conn.on('data', function(data) {
                resolve(data)
              })
              conn.send({
                type: 'get:room',
                payload: {
                  roomId: roomId
                }
              })
            })
          })
        })
      }
    },
    createRoom: function (room) {
      return loadPeerJs().then(function (Peer) {
        localStorage.setItem('/rooms/' + room.id, JSON.stringify(room))
        var peer = new Peer('elm-gameroom-' + room.id, peerOptions)
        peerClientsByRoomId[room.id] = {
          peer: peer,
          isHost: true
        }
        peer.on('connection', function(conn) {
          conn.on('data', function (msg) {
            if (msg.type === 'get:room') {
              conn.send(JSON.parse(localStorage.getItem('/rooms/' + msg.payload.roomId)))
            }
          })
        })
      })
    }
  }
}

if (typeof module === 'object' && module.exports) {
  module.exports = db
} else {
  window.db = db
}
