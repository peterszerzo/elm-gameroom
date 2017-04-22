module Models.Game exposing (..)

import Models.Room exposing (Room)


type alias Game problem guess =
    { roomId : String
    , playerId : String
    , room : Maybe (Room problem guess)
    , ticksSinceNewRound : Int
    }
