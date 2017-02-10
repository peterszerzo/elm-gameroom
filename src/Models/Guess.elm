module Models.Guess exposing (..)

import Json.Decode as JD


type alias GuessWithTimestamp guessType =
    { value : guessType
    , madeAt : Float
    }


withTimestampDecoder : JD.Decoder guessType -> JD.Decoder (GuessWithTimestamp guessType)
withTimestampDecoder guessDecoder =
    JD.map2 GuessWithTimestamp
        (JD.field "value" guessDecoder)
        (JD.field "madeAt" JD.float)
