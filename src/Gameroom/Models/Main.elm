module Gameroom.Models.Main exposing (..)

import Gameroom.Router as Router


type alias Model problemType guessType =
    { route : Router.Route problemType guessType
    }
