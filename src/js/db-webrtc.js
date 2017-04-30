/*
 * Prototype, not working yet..
 */

function loadPeer () {
  var url = 'http://cdn.peerjs.com/0.3/peer.min.js'
  // TODO: finish async loading script
}

function testConnection () {
  var options = {
    key: 'lwjd5qra8257b9'
  }

  var peer1 = new Peer('apples', options)
  var peerId1

  var peer2 = new Peer('oranges', options)
  var peerId2

  var connection = peer2.connect('apples')

  connection.on('open', function () {
    connection.send('Hello!')
  })

  peer1.on('connection', function (conn) {
    conn.on('data', console.log.bind(console))
  })

  peer1.on('open', function (id) {
    peerId1 = id
  })

  peer2.on('open', function (id) {
    peerId2 = id
  })
}
