module Data.Room exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Data.Spec as Spec
import Data.Player as Player
import Data.Round as Round
import Constants exposing (nullString)


-- Type definitions


type alias RoomId =
    String


type alias Room problem guess =
    { id : String
    , host : Player.PlayerId
    , round : Maybe (Round.Round problem)
    , players : Dict.Dict String (Player.Player guess)
    }



-- Helpers


create : RoomId -> List Player.PlayerId -> Room problem guess
create roomId playerIds =
    { id = roomId
    , host = playerIds |> List.head |> Maybe.withDefault ""
    , round = Nothing
    , players = Dict.fromList (List.map (\playerId -> ( playerId, Player.create playerId roomId )) playerIds)
    }


updatePreservingLocalGuesses : Room problem guess -> Room problem guess -> Room problem guess
updatePreservingLocalGuesses newRoom oldRoom =
    -- Since the application state only listens to full room updates,
    -- it can occur that one player's guess is nulled by another player's update.
    -- This method protects agains that.
    let
        didRoundChange =
            Maybe.map2
                (\newRound round -> newRound.no /= round.no)
                newRoom.round
                oldRoom.round
                |> Maybe.withDefault True

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
                                        && (player.guess == Nothing)
                                    )
                                then
                                    oldRoom.players
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


allPlayersGuessed : Room problem guess -> Bool
allPlayersGuessed room =
    room.players
        |> Dict.toList
        |> List.map Tuple.second
        |> List.map .guess
        |> List.all ((/=) Nothing)


bigNumber : Float
bigNumber =
    100000


getRoundWinner : Spec.DetailedSpec problem guess -> Room problem guess -> Maybe Player.PlayerId
getRoundWinner spec room =
    room.players
        |> Dict.toList
        |> List.filterMap
            (\( playerId, player ) ->
                player.guess
                    |> Maybe.map2
                        (\round guess ->
                            ( playerId
                            , spec.evaluate round.problem guess.value
                            , guess.madeAt
                            )
                        )
                        room.round
            )
        |> List.sortWith
            (\( playerId1, eval1, madeAt1 ) ( playerId2, eval2, madeAt2 ) ->
                if eval1 > eval2 then
                    LT
                else if eval1 < eval2 then
                    GT
                else
                    (if madeAt1 > madeAt2 then
                        GT
                     else
                        LT
                    )
            )
        |> List.head
        |> Maybe.map
            (\( playerId, eval, _ ) ->
                case spec.clearWinnerEvaluation of
                    Just clearWinnerEval ->
                        if eval == clearWinnerEval then
                            Just playerId
                        else
                            Nothing

                    Nothing ->
                        Just playerId
            )
        |> Maybe.withDefault Nothing


updatePlayer :
    (Player.Player guess -> Player.Player guess)
    -> Player.PlayerId
    -> Room problem guess
    -> Room problem guess
updatePlayer transform playerId room =
    case (Dict.get playerId room.players) of
        Just player ->
            { room | players = Dict.insert playerId (transform player) room.players }

        Nothing ->
            room


setScores :
    Maybe Player.PlayerId
    -> Room problem guess
    -> Room problem guess
setScores maybeWinnerId room =
    { room
        | players =
            case maybeWinnerId of
                Just winnerId ->
                    room.players
                        |> Dict.toList
                        |> List.map
                            (\( playerId, player ) ->
                                if playerId == winnerId then
                                    ( playerId
                                    , { player
                                        | score = player.score + 1
                                      }
                                    )
                                else
                                    ( playerId
                                    , player
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
        , ( "round"
          , case room.round of
                Nothing ->
                    JE.string nullString

                Just round ->
                    Round.encoder problemEncoder round
          )
        ]



-- Decoders


decoder : JD.Decoder problem -> JD.Decoder guess -> JD.Decoder (Room problem guess)
decoder problemDecoder guessDecoder =
    JD.map4 Room
        (JD.field "id" JD.string)
        (JD.field "host" JD.string)
        (JD.field "round"
            (JD.oneOf
                [ JD.string
                    |> JD.andThen
                        (\s ->
                            if s == nullString then
                                JD.succeed Nothing
                            else
                                JD.fail "Not recognized"
                        )
                , Round.decoder problemDecoder
                    |> JD.andThen (\round -> JD.succeed (Just round))
                ]
            )
        )
        (JD.field "players" (JD.dict (Player.decoder guessDecoder)))
