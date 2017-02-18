port module Gameroom.Ports exposing (..)


port disconnectFromRoom : String -> Cmd msg


port connectToRoom : String -> Cmd msg


port updateRoom : String -> Cmd msg


port roomUpdated : (String -> msg) -> Sub msg


port createRoom : String -> Cmd msg


port roomCreated : (String -> msg) -> Sub msg
