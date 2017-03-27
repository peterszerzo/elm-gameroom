module Gameroom.Models.Game exposing (..)

import Gameroom.Models.Room exposing (Room)


type alias Game problem guess =
    { roomId : String
    , playerId : String
    , room : Maybe (Room problem guess)
    , roundTime : Float
    }
