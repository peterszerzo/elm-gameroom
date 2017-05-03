module Models.Guess exposing (..)

import Json.Decode as JD


type alias Guess guess =
    { value : guess
    , madeAt : Int
    }


decoder : JD.Decoder guess -> JD.Decoder (Guess guess)
decoder guessDecoder =
    JD.map2 Guess
        (JD.field "value" guessDecoder)
        (JD.field "madeAt" JD.int)
