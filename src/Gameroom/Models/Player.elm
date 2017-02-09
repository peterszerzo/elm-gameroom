module Models.Player exposing (..)

import Models.Guess as Guess
import Json.Decode as JD


type alias Player guessType =
    { id : String
    , isReady : Bool
    , score : Int
    , guess :
        Maybe (Guess.GuessWithTimestamp guessType)
    }


decoder : JD.Decoder guessType -> JD.Decoder (Player guessType)
decoder guessDecoder =
    JD.map4 Player
        (JD.field "id" JD.string)
        (JD.field "isReady" JD.bool)
        (JD.field "score" JD.int)
        (JD.field "guess" (JD.nullable (Guess.withTimestampDecoder guessDecoder)))
