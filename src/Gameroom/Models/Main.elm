module Gameroom.Models.Main exposing (..)

import Gameroom.Router as Router
import Gameroom.Models.Result


type alias Model problemType guessType =
    { route : Router.Route problemType guessType
    }
