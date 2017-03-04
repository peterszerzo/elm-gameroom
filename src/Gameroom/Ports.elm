module Gameroom.Ports exposing (..)

{-| elm-gameroom communicates with its backend through a couple of well-defined ports. This module explains how they're wired up in detail.

See the [JavaScript utilities](https://github.com/peterszerzo/elm-gameroom/blob/master/src/js/README.md) docs for a detailed explanation and examples on how ports are wired up for things to work.

# The Ports record
@docs Ports

# Ports from Elm to JavaScript
@docs SubscribeToRoom
@docs UnsubscribeFromRoom
@docs CreateRoom
@docs UpdateRoom
@docs UpdatePlayer

# Ports from JavaScript to Elm
@docs RoomCreated
@docs RoomUpdated
@docs PlayerUpdated
-}


{-| The Ports record contains all ports necessary for a guessing game. The client is responsible for declaring them, passing them to the game-generator `program` method, and hooking them up with the realtime back-end. Head to the examples in the repo for some simple usage.

Required ports are the following:

    type alias Ports msg =
        { subscribeToRoom : String -> Cmd msg
        , unsubscribeFromRoom : String -> Cmd msg
        , createRoom : String -> Cmd msg
        , updateRoom : String -> Cmd msg
        , roomCreated : (String -> msg) -> Sub msg
        , roomUpdated : (String -> msg) -> Sub msg
        }

Their detailed uses are the following:

* `unsubscribeFromRoom(id : String)`: unsubscribe from a gameroom with a given id.
* `subscribeToRoom(id : String)`: subscribes to a gameroom with a given id, sending changes to the `roomUpdated` port. Requires that the value of a room at the time of subscription also be sent to `roomUpdated`.
* `updateRoom(room : String)`: updates a given game room through a stringified JSON representation.
* `roomUpdated() : String`: receives a game room update.
* `createRoom(room : String)`: creates a game room based on a stringified JSON representation.
* `roomCreated(room : String)`: signals that a room has been created.
-}
type alias Ports msg =
    { subscribeToRoom : SubscribeToRoom msg
    , unsubscribeFromRoom : UnsubscribeFromRoom msg
    , createRoom : CreateRoom msg
    , updateRoom : UpdateRoom msg
    , updatePlayer : UpdatePlayer msg
    , roomCreated : RoomCreated msg
    , roomUpdated : RoomUpdated msg
    , playerUpdated : PlayerUpdated msg
    }


{-| Unsubscribe from game room. This port should receive a room id as a string. After a value is received, the corresponding room should stop sending updates to the RoomUpdated port.
-}
type alias UnsubscribeFromRoom msg =
    String -> Cmd msg


{-| Subscribe to game room. This port should receive a room id as a string. After a value is received, the corresponding room should start sending updates to the RoomUpdated port.
-}
type alias SubscribeToRoom msg =
    String -> Cmd msg


{-| Create a game room. This port should receive a stringified room object, to signal that the room has been updated by one of the clients.

In JavaScript, you would send something like the following:

    ports.createRoom.send(
      JSON.stringify({
        id: 'theroom',
        players: {}/*, ... */
      })
    )
-}
type alias CreateRoom msg =
    String -> Cmd msg


{-| Update a game room. This port receives a stringified room object, to signal that the room has been updated by one of the clients.

In JavaScript, you would send something like the following:

    ports.updateRoom.send(
      JSON.stringify({
        id: 'theroom',
        players: '...'
      })
    )
-}
type alias UpdateRoom msg =
    String -> Cmd msg


{-| Update a single player. This port should receive a stringified player object, to signal that the player has been updated by one of the clients.

In JavaScript, you would send something like the following:

    ports.updatePlayer.send(
      JSON.stringify({
        id: 'player',
        guess: '...'
      })
    )
-}
type alias UpdatePlayer msg =
    String -> Cmd msg


{-| Response from JavaScript, signalling that a gameroom has been created. Sends back the stringified room object to Elm.
-}
type alias RoomCreated msg =
    (String -> msg) -> Sub msg


{-| Response from JavaScript, signalling that an entire game room has been updated. Sends the stringified room object to Elm.
-}
type alias RoomUpdated msg =
    (String -> msg) -> Sub msg


{-| Response from JavaScript, signalling that a single player has been updated. Sends the stringified room object to Elm.
-}
type alias PlayerUpdated msg =
    (String -> msg) -> Sub msg
