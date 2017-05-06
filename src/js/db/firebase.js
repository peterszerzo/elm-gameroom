/**
 * Firebase data store
 * @returns {Object} db - Datastore instance, following elm-gameroom API.
 */
 (function (root, factory) {
   if (typeof module === 'object' && module.exports) {
     module.exports = factory(root)
   } else {
     root.db = factory(root)
   }
 }(this, function (window) {
   var db = function (firebaseConfig) {
     var firebase = window.firebase

     var config = firebaseConfig || {
       apiKey: process.env.FIREBASE_API_KEY,
       authDomain: process.env.FIREBASE_AUTH_DOMAIN,
       databaseURL: process.env.FIREBASE_DATABASE_URL,
       storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
       messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID
     }

     var firebaseApp = firebase.initializeApp(config)

     var database = firebaseApp.database()

     return {
       getRoom: function (roomId) {
         return database.ref('/rooms/' + roomId).once('value').then(function (snapshot) {
           return snapshot.val()
         })
       },

       createRoom: function (room) {
         return database.ref('/rooms/' + room.id).set(room)
       },

       updateRoom: function (room) {
         return database.ref('/rooms/' + room.id).set(room)
       },

       updatePlayer: function (player) {
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
   }

   return db
 }))
