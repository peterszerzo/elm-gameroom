module Models.Round exposing (..)

import Json.Decode as JD
import Json.Encode as JE


type alias Round problem =
    { no : Int
    , problem : problem
    , isDecided : Bool
    }


encoder : (problem -> JE.Value) -> (Round problem -> JE.Value)
encoder problemEncoder round =
    JE.object
        [ ( "no", JE.int round.no )
        , ( "problem", problemEncoder round.problem )
        , ( "isDecided", JE.bool round.isDecided )
        ]


decoder : JD.Decoder problem -> JD.Decoder (Round problem)
decoder problemDecoder =
    JD.map3 Round
        (JD.field "no" JD.int)
        (JD.field "problem" problemDecoder)
        (JD.field "isDecided" JD.bool)
