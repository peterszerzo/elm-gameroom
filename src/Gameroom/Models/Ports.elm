module Gameroom.Models.Ports exposing (..)


type alias Ports msg =
    { unsubscribeFromRoom : String -> Cmd msg
    , subscribeToRoom : String -> Cmd msg
    , updateRoom : String -> Cmd msg
    , roomUpdated : (String -> msg) -> Sub msg
    , createRoom : String -> Cmd msg
    , roomCreated : (String -> msg) -> Sub msg
    }
