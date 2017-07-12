module Data.Round exposing (..)

import Json.Decode as JD
import Json.Encode as JE


type alias Round problem =
    { no : Int
    , problem : problem
    }


encoder : (problem -> JE.Value) -> (Round problem -> JE.Value)
encoder problemEncoder round =
    JE.object
        [ ( "no", JE.int round.no )
        , ( "problem", problemEncoder round.problem )
        ]


decoder : JD.Decoder problem -> JD.Decoder (Round problem)
decoder problemDecoder =
    JD.map2 Round
        (JD.field "no" JD.int)
        (JD.field "problem" problemDecoder)
