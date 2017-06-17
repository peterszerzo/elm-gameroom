module Models.Tutorial exposing (..)

import Models.RoundTime as RoundTime


type alias Tutorial problem guess =
    { problem : Maybe problem
    , guess : Maybe guess
    , time : RoundTime.RoundTime
    }


init : Tutorial problem guess
init =
    { problem = Nothing
    , guess = Nothing
    , time = RoundTime.init
    }
