port module Gameroom.Ports exposing (..)


port unsubscribeFromRoom : String -> Cmd msg


port subscribeToRoom : String -> Cmd msg


port updateRoom : String -> Cmd msg


port roomUpdated : (String -> msg) -> Sub msg


port createRoom : String -> Cmd msg


port roomCreated : (String -> msg) -> Sub msg
