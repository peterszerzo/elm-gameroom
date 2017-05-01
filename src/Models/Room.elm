module Models.Room exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Models.Player as Player
import Constants exposing (nullString)


-- Type definitions


type alias Round problem =
    { no : Int
    , problem : Maybe problem
    }


type alias Room problem guess =
    { id : String
    , host : String
    , round :
        { no : Int
        , problem : Maybe problem
        }
    , players : Dict.Dict String (Player.Player guess)
    }



-- Helpers


create : String -> List String -> Room problem guess
create roomId playerIds =
    { id = roomId
    , host = playerIds |> List.head |> Maybe.withDefault ""
    , round = { no = 0, problem = Nothing }
    , players = Dict.fromList (List.map (\playerId -> ( playerId, Player.create playerId roomId )) playerIds)
    }


updatePreservingLocalGuesses : Room problem guess -> Room problem guess -> Room problem guess
updatePreservingLocalGuesses newRoom room =
    -- Since the application state only listens to full room updates,
    -- it can occur that one player's guess is nulled by another player's update.
    -- This method protects agains that.
    let
        didRoundChange =
            newRoom.round.no /= room.round.no

        newPlayers =
            newRoom.players
                |> Dict.toList
                |> List.map
                    (\( playerId, player ) ->
                        ( playerId
                        , { player
                            | guess =
                                -- If the round didn't change, and the new guess is Nothing
                                -- keep the old guess, which may be something.
                                if
                                    (not didRoundChange
                                        && player.guess
                                        == Nothing
                                    )
                                then
                                    room.players
                                        |> Dict.get playerId
                                        |> Maybe.map .guess
                                        |> Maybe.withDefault player.guess
                                else
                                    player.guess
                          }
                        )
                    )
                |> Dict.fromList
    in
        { newRoom | players = newPlayers }


allPlayersReady : Room problem guess -> Bool
allPlayersReady room =
    room.players
        |> Dict.toList
        |> List.map Tuple.second
        |> List.map .isReady
        |> List.all identity


updatePlayer :
    (Player.Player guess -> Player.Player guess)
    -> String
    -> Room problem guess
    -> Room problem guess
updatePlayer transform playerId room =
    case (Dict.get playerId room.players) of
        Just player ->
            { room | players = Dict.insert playerId (transform player) room.players }

        Nothing ->
            room


setNewRound :
    Maybe String
    -> Room problem guess
    -> Room problem guess
setNewRound maybeWinnerId room =
    { room
        | round = { no = room.round.no + 1, problem = Nothing }
        , players =
            case maybeWinnerId of
                Just winnerId ->
                    room.players
                        |> Dict.toList
                        |> List.map
                            (\( playerId, player ) ->
                                if playerId == winnerId then
                                    ( playerId
                                    , { player
                                        | guess = Nothing
                                        , score = player.score + 1
                                      }
                                    )
                                else
                                    ( playerId
                                    , { player
                                        | guess = Nothing
                                      }
                                    )
                            )
                        |> Dict.fromList

                Nothing ->
                    room.players
    }



-- Encoders


encoder : (problem -> JE.Value) -> (guess -> JE.Value) -> Room problem guess -> JE.Value
encoder problemEncoder guessEncoder room =
    JE.object
        [ ( "id", JE.string room.id )
        , ( "host", JE.string room.host )
        , ( "players", Player.collectionEncoder guessEncoder room.players )
        , ( "round", roundEncoder problemEncoder room.round )
        ]


roundEncoder : (problem -> JE.Value) -> (Round problem -> JE.Value)
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


decoder : JD.Decoder problem -> JD.Decoder guess -> JD.Decoder (Room problem guess)
decoder problemDecoder guessDecoder =
    JD.map4 Room
        (JD.field "id" JD.string)
        (JD.field "host" JD.string)
        (JD.field "round" (roundDecoder problemDecoder))
        (JD.field "players" (JD.dict (Player.decoder guessDecoder)))


roundDecoder : JD.Decoder problem -> JD.Decoder (Round problem)
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
