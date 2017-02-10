module Models.Room exposing (..)

import Dict
import Models.Player as Player
import Json.Decode as JD


type RoundStatus
    = Prep
    | Active
    | Cooldown


type alias Round problemType =
    { no : Int
    , status : RoundStatus
    , problem : Maybe problemType
    }


type alias Room problemType guessType =
    { id : String
    , host : String
    , round :
        { no : Int
        , status : RoundStatus
        , problem : Maybe problemType
        }
    , players : Dict.Dict String (Player.Player guessType)
    }


decoder : JD.Decoder (Maybe problemType) -> JD.Decoder guessType -> JD.Decoder (Room problemType guessType)
decoder problemDecoder guessDecoder =
    JD.map4 Room
        (JD.field "id" JD.string)
        (JD.field "host" JD.string)
        (JD.field "round" (roundDecoder problemDecoder))
        (JD.field "players" (JD.dict (Player.decoder guessDecoder)))


roundDecoder : JD.Decoder (Maybe problemType) -> JD.Decoder (Round problemType)
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
