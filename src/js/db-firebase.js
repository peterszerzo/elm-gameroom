/**
 * Firebase data store
 *
 */

var firebase = global.firebase

var config = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.FIREBASE_DATABASE_URL,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID
}

var firebaseApp = firebase.initializeApp(config)

var database = firebaseApp.database()

var db = {
  getRoom: function (roomId) {
    return database.ref('/rooms/' + roomId).once('value').then(function (snapshot) {
      return snapshot.val()
    })
  },
  setRoom: function (room) {
    return database.ref('/rooms/' + room.id).set(room)
  },
  setPlayer: function (player) {
    return database.ref('/rooms/' + player.roomId + '/players/' + player.id).set(player)
  },
  subscribeToRoom: function (roomId, next) {
    return database.ref('/rooms/' + roomId).on('value', function (snapshot) {
      next(snapshot.val())
    })
  },
  unsubscribeFromRoom: function (roomId) {
    return database.ref('/rooms/' + roomId).off()
  }
}

if (typeof module === 'object' && module.exports) {
  module.exports = db
} else {
  window.db = db
}
