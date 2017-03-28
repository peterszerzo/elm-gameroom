module Models.Guess exposing (..)

import Json.Decode as JD


type alias GuessWithTimestamp guess =
    { value : guess
    , madeAt : Float
    }


withTimestampDecoder : JD.Decoder guess -> JD.Decoder (GuessWithTimestamp guess)
withTimestampDecoder guessDecoder =
    JD.map2 GuessWithTimestamp
        (JD.field "value" guessDecoder)
        (JD.field "madeAt" JD.float)
