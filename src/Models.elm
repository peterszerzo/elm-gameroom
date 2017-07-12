module Models exposing (..)

import Router
import Window


type alias Model problem guess =
    { route : Router.Route problem guess
    , windowSize : Window.Size
    }
