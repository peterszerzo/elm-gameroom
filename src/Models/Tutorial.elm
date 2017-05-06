module Models.Tutorial exposing (..)


type alias Tutorial problem guess =
    { problem : Maybe problem
    , guess : Maybe guess
    , animationTicksSinceNewRound : Int
    }


init : Tutorial problem guess
init =
    { problem = Nothing
    , guess = Nothing
    , animationTicksSinceNewRound = 0
    }
