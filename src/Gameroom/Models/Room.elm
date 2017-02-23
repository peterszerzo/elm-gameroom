module Gameroom.Models.Room exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Gameroom.Models.Player as Player
import Gameroom.Constants exposing (nullString)


-- Type definitions


type alias Round problemType =
    { no : Int
    , problem : Maybe problemType
    }


type alias Room problemType guessType =
    { id : String
    , host : String
    , round :
        { no : Int
        , problem : Maybe problemType
        }
    , players : Dict.Dict String (Player.Player guessType)
    }



-- Helpers


create : String -> List String -> Room problemType guessType
create roomId playerIds =
    { id = roomId
    , host = playerIds |> List.head |> Maybe.withDefault ""
    , round = { no = 0, problem = Nothing }
    , players = Dict.fromList (List.map (\playerId -> ( playerId, Player.create playerId )) playerIds)
    }


allPlayersReady : Room problemType guessType -> Bool
allPlayersReady room =
    room.players
        |> Dict.toList
        |> List.map Tuple.second
        |> List.map .isReady
        |> List.all identity


updatePlayer : (Player.Player guessType -> Player.Player guessType) -> String -> Room problemType guessType -> Room problemType guessType
updatePlayer transform playerId room =
    case (Dict.get playerId room.players) of
        Just player ->
            { room | players = Dict.insert playerId (transform player) room.players }

        Nothing ->
            room



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
    JD.map2 Round
        (JD.field "no" JD.int)
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
