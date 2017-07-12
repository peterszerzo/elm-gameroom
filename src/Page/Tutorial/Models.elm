module Page.Tutorial.Models exposing (..)

import Data.RoundTime as RoundTime


type alias Model problem guess =
    { problem : Maybe problem
    , guess : Maybe guess
    , time : RoundTime.RoundTime
    }


init : Model problem guess
init =
    { problem = Nothing
    , guess = Nothing
    , time = RoundTime.init
    }
