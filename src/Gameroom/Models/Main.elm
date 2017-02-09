module Models.Main exposing (..)

import Router


type alias Model problemType guessType =
    { route : Router.Route problemType guessType
    }
