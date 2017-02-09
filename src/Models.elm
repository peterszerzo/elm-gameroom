module Models exposing (..)

import Dict
import Json.Decode as JD


type RoundStatus
    = Prep
    | Active
    | Cooldown


type alias Model problemType guessType =
    { playerId : String
    , room : Maybe (Room problemType guessType)
    }


type alias Round problemType =
    { no : Int
    , status : RoundStatus
    , problem : problemType
    }


type alias GuessWithTimestamp guessType =
    { value : guessType
    , madeAt : Float
    }


type alias Player guessType =
    { id : String
    , isReady : Bool
    , score : Int
    , guess :
        Maybe (GuessWithTimestamp guessType)
    }


type alias Room problemType guessType =
    { id : String
    , host : String
    , round :
        { no : Int
        , status : RoundStatus
        , problem : problemType
        }
    , players : Dict.Dict String (Player guessType)
    }


guessWithTimestampDecoder : JD.Decoder guessType -> JD.Decoder (GuessWithTimestamp guessType)
guessWithTimestampDecoder guessDecoder =
    JD.map2 GuessWithTimestamp
        (JD.field "value" guessDecoder)
        (JD.field "madeAt" JD.float)


playerDecoder : JD.Decoder guessType -> JD.Decoder (Player guessType)
playerDecoder guessDecoder =
    JD.map4 Player
        (JD.field "id" JD.string)
        (JD.field "isReady" JD.bool)
        (JD.field "score" JD.int)
        (JD.field "guess" (JD.nullable (guessWithTimestampDecoder guessDecoder)))


roundDecoder : JD.Decoder problemType -> JD.Decoder (Round problemType)
roundDecoder problemDecoder =
    JD.map3 Round
        (JD.field "no" JD.int)
        (JD.field "status"
            (JD.string
                |> JD.andThen
                    (\s ->
                        JD.succeed <|
                            case s of
                                "prep" ->
                                    Prep

                                "active" ->
                                    Active

                                _ ->
                                    Cooldown
                    )
            )
        )
        (JD.field "problem" problemDecoder)


roomDecoder : JD.Decoder problemType -> JD.Decoder guessType -> JD.Decoder (Room problemType guessType)
roomDecoder problemDecoder guessDecoder =
    JD.map4 Room
        (JD.field "id" JD.string)
        (JD.field "host" JD.string)
        (JD.field "round" (roundDecoder problemDecoder))
        (JD.field "players" (JD.dict (playerDecoder guessDecoder)))
