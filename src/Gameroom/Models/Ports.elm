module Gameroom.Models.Ports exposing (..)


type alias Ports msg =
    { incoming : (String -> msg) -> Sub msg
    , outgoing : String -> Cmd msg
    }
