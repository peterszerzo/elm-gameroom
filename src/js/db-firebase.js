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

module.exports = {
  /**
   * @param {string} roomId - Room id.
   * @return {Promise}
   */
  getRoom: function (roomId) {
    return database.ref('/rooms/' + roomId).once('value').then(function (snapshot) {
      return snapshot.val()
    })
  },

  /**
   * @param {string} stringified room object.
   * @return {Promise}
   */
  setRoom: function (room) {
    return database.ref('/rooms/' + room.id).set(room)
  },

  /**
   * @param {string} roomId - Room id.
   * @param {function} onValue - Update callback.
   * @return {function} onValue
   */
  subscribeToRoom: function (roomId, next) {
    return database.ref('/rooms/' + roomId).on('value', function (snapshot) {
      next(snapshot.val())
    })
  },

  /**
   * @param {string} roomId - Room id.
   */
  unsubscribeFromRoom: function (roomId) {
    return database.ref('/rooms/' + roomId).off()
  }
}
