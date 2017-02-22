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

module.exports = {
  getRoom: function (roomId) {
    return database.ref('/rooms/' + roomId).once('value').then(function (snapshot) {
      return snapshot.val()
    })
  },
  setRoom: function (room, next) {
    return database.ref('/rooms/' + room.id).set(room).then(function (room) {
      next()
    })
  },
  setGuess: function (roomId, playerId, guess) {
    return database.ref('/rooms/' + roomId + '/players/' + playerId + '/guess', guess)
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
