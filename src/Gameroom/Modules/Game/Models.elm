module Gameroom.Modules.Game.Models exposing (..)

import Gameroom.Models.Room exposing (Room)


type alias Model problemType guessType =
    { roomId : String
    , playerId : String
    , room : Maybe (Room problemType guessType)
    , roundTime : Float
    }
