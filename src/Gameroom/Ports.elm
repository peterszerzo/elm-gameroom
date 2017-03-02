module Gameroom.Ports exposing (..)

{-| elm-gameroom communicates with its backend through a couple of well-defined ports. This module explains how they're wired up in detail.

# Main
@docs Ports
-}


{-| The Ports record contains all ports necessary for a guessing game. The client is responsible for declaring them, passing them to the game-generator `program` method, and hooking them up with the realtime back-end. Head to the examples in the repo for some simple usage.

Required ports are the following:

    type alias Ports msg =
        { unsubscribeFromRoom : String -> Cmd msg
        , subscribeToRoom : String -> Cmd msg
        , updateRoom : String -> Cmd msg
        , roomUpdated : (String -> msg) -> Sub msg
        , createRoom : String -> Cmd msg
        , roomCreated : (String -> msg) -> Sub msg
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
    { unsubscribeFromRoom : String -> Cmd msg
    , subscribeToRoom : String -> Cmd msg
    , updateRoom : String -> Cmd msg
    , roomUpdated : (String -> msg) -> Sub msg
    , createRoom : String -> Cmd msg
    , roomCreated : (String -> msg) -> Sub msg
    }
