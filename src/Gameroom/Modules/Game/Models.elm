module Gameroom.Modules.Game.Models exposing (..)

import Gameroom.Models.Room exposing (Room)


type alias Model problem guess =
    { roomId : String
    , playerId : String
    , room : Maybe (Room problem guess)
    , roundTime : Float
    }
