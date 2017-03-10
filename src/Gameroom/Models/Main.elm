module Gameroom.Models.Main exposing (..)

import Gameroom.Router as Router


type alias Model problem guess =
    { route : Router.Route problem guess
    }
