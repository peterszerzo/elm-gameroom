/**
 * This function handles communication between the Elm ports and the datastore.
 * @param {object} db - datastore API
 * @param {object} ports - Elm ports
 * @return {object} ports
 */
 ;(function (root, factory) {
   if (typeof module === 'object' && module.exports) {
     module.exports = factory(root)
   } else {
     root.talkToPorts = factory(root)
   }
 }(this, function (window) {
   return function talkToPorts (db, ports) {
     ports.outgoing.subscribe(function (data) {
       var type = data.type
       var payload = data.payload
       switch (type) {
         // Subscribe to room, sending room:updated messages
         case 'subscribeto:room':
           return db.subscribeToRoom(payload, function (room) {
             ports.incoming.send({
               type: 'room:updated',
               payload: room
             })
           })
         // Unsubscribe from room, making sure room:updated messages are no longer sent
         case 'unsubscribefrom:room':
           return db.unsubscribeFromRoom(payload)
         // Create new game room in storage, sending back a room:created message.
         case 'create:room':
           return db.createRoom(payload).then(function () {
             ports.incoming.send({
               type: 'room:created',
               payload: payload
             })
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
 }))
