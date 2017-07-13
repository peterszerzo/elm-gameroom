module Models exposing (..)

import Data.Route exposing (Route)
import Window


type alias Model problem guess =
    { route : Route problem guess
    , windowSize : Window.Size
    }
