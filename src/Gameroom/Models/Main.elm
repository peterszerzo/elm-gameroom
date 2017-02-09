module Models.Main exposing (..)

import Models.Room exposing (Room)
import Router


type alias Model problemType guessType =
    { playerId : String
    , room : Maybe (Room problemType guessType)
    , route : Router.Route problemType guessType
    }
