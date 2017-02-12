module Models.Game exposing (..)

import Models.Room exposing (Room)


type alias Game problemType guessType =
    { roomId : String
    , playerId : String
    , room : Maybe (Room problemType guessType)
    }
