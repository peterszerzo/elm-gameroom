module Models exposing (..)

import Dict


type RoundStatus
    = Prep
    | Active
    | Cooldown


type alias Player guessType =
    { id : String
    , isReady : Bool
    , score : Int
    , guess :
        Maybe
            { value : guessType
            , madeAt : Float
            }
    }


type alias Room problemType guessType =
    { host : String
    , round :
        { no : Int
        , status : RoundStatus
        , problem : problemType
        }
    , players : Dict.Dict String (Player guessType)
    }
