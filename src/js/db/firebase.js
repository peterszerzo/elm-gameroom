/**
 * Firebase data store
 * @returns {Object} db - Datastore instance, following elm-gameroom API.
 */
 ;(function (root, factory) {
   if (typeof module === 'object' && module.exports) {
     module.exports = factory(root)
   } else {
     root.db = factory(root)
   }
 }(this, function (window) {
   var db = function (firebaseConfig, options) {
     var firebase = window.firebase

     var rootRef = (options && options.rootRef) || ''

     var firebaseApp = firebase.initializeApp(firebaseConfig)

     var database = firebaseApp.database()

     return {
       getRoom: function (roomId) {
         return database.ref(rootRef + '/rooms/' + roomId)
         .once('value')
         .then(function (snapshot) {
           return snapshot.val()
         })
       },

       createRoom: function (room) {
         return database.ref(rootRef + '/rooms/' + room.id).set(room)
       },

       updateRoom: function (room) {
         return database.ref(rootRef + '/rooms/' + room.id).set(room)
       },

       updatePlayer: function (player) {
         return database.ref(rootRef + '/rooms/' + player.roomId + '/players/' + player.id).set(player)
       },

       subscribeToRoom: function (roomId, next) {
         return database.ref(rootRef + '/rooms/' + roomId).on('value', function (snapshot) {
           next(snapshot.val())
         })
       },

       unsubscribeFromRoom: function (roomId) {
         return database.ref(rootRef + '/rooms/' + roomId).off()
       }
     }
   }

   return db
 }))
