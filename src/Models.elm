module Models exposing (..)

import Router as Router


type alias Model problem guess =
    { route : Router.Route problem guess
    }
