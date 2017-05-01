# elm-gameroom JavaScript utilities

An Elm app running on `elm-gameroom` needs a thin piece of JavaScript that talks to a generic backend. This folder provides a generic datastore API implemented in generic backends, as well as the of glue code that talks to the Elm app's ports.

These pieces of JavaScript are considered boilerplate, and `elm-gameroom` aims to keep them to a minimum.

## db

The `db/*.js` files each export a function taking in some configuration, and returning an object with methods that interact with the back-end. This API is the following:

```js
{
  getRoom: function (id) {
    // Retrieves the room object by a given id.
  },

  setRoom: function (room) {
    // Stores the room object coming from Elm in the datastore.
  },

  subscribeToRoom: function (roomId, onValue) {
    // Subscribes to a room, calling callback when it changes (including at the start)
  },

  unsubscribeFromRoom: function (roomId) {
    // Clears all subscribers from the given room for the given client
  },

  setPlayer: function (player) {
    // Sets a player, nested inside the room under the players field.
    // Note that the player object contains an id and roomId fields.
    // E.g. in Firebase, they can be found under the key:
    // `/rooms/${player.roomId}/players/${player.id}`
  }
}
```

## talk-to-ports.js

If your database implementation follows the `db` API, then you can use this piece of code to talk to your Elm ports, as follows:

```js
import talkToPorts from '~/elm-stuff/packages/peterszerzo/elm-gameroom/1.0.0/src/js/talk-to-ports'

// Import local storage db implementation
import db from '~/elm-stuff/packages/peterszerzo/elm-gameroom/1.0.0/src/js/db/local-storage'

// Start Elm app
const app = Elm.Main.embed(document.getElementById('root'))

// Talk to Elm's ports
talkToPorts(db, app.ports)
```
