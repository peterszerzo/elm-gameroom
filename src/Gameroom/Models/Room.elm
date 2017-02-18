module Gameroom.Models.Room exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Gameroom.Models.Player as Player
import Gameroom.Constants exposing (nullString)


-- Type definitions


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



-- Helpers


create : String -> List String -> Room problemType guessType
create roomId playerIds =
    { id = roomId
    , host = playerIds |> List.head |> Maybe.withDefault ""
    , round = { no = 0, status = Prep, problem = Nothing }
    , players = Dict.fromList (List.map (\playerId -> ( playerId, Player.create playerId )) playerIds)
    }



-- Encoders


encoder : (problemType -> JE.Value) -> (guessType -> JE.Value) -> (Room problemType guessType -> JE.Value)
encoder problemEncoder guessEncoder room =
    JE.object
        [ ( "id", JE.string room.id )
        , ( "host", JE.string room.host )
        , ( "players", Player.collectionEncoder guessEncoder room.players )
        , ( "round", roundEncoder problemEncoder room.round )
        ]


roundEncoder : (problemType -> JE.Value) -> (Round problemType -> JE.Value)
roundEncoder problemEncoder round =
    JE.object
        [ ( "no", JE.int round.no )
        , ( "status"
          , (case round.status of
                Prep ->
                    "prep"

                Active ->
                    "active"

                Cooldown ->
                    "cooldown"
            )
                |> JE.string
          )
        , ( "problem"
          , case round.problem of
                Nothing ->
                    JE.string nullString

                Just problem ->
                    problemEncoder problem
          )
        ]



-- Decoders


decoder : JD.Decoder problemType -> JD.Decoder guessType -> JD.Decoder (Room problemType guessType)
decoder problemDecoder guessDecoder =
    JD.map4 Room
        (JD.field "id" JD.string)
        (JD.field "host" JD.string)
        (JD.field "round" (roundDecoder problemDecoder))
        (JD.field "players" (JD.dict (Player.decoder guessDecoder)))


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
        (JD.field "problem" <|
            JD.oneOf
                [ JD.string
                    |> JD.andThen
                        (\s ->
                            if s == nullString then
                                JD.succeed Nothing
                            else
                                JD.fail "Not recognized."
                        )
                , problemDecoder
                    |> JD.andThen
                        (\pb -> JD.succeed (Just pb))
                ]
        )
