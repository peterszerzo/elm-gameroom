module Page.Game.Update exposing (..)

import Dict
import Json.Encode as JE
import Data.OutgoingMessage as OutgoingMessage
import Page.Game.Messages exposing (Msg(..))
import Page.Game.Models exposing (Model, setOwnGuess, getOwnPlayer)
import Data.Room as Room
import Data.Player as Player
import Data.RoundTime as RoundTime
import Data.Spec as Spec


updateRoomCmd :
    Spec.DetailedSpec problem guess
    -> Model problem guess
    -> Maybe JE.Value
updateRoomCmd spec model =
    model.room
        |> Maybe.map (OutgoingMessage.UpdateRoom >> (OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder))


updatePlayerCmd :
    Spec.DetailedSpec problem guess
    -> Maybe (Player.Player guess)
    -> Maybe JE.Value
updatePlayerCmd spec player =
    player
        |> Maybe.map (OutgoingMessage.UpdatePlayer >> (OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder))


update :
    Spec.DetailedSpec problem guess
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, List JE.Value, Bool )
update spec msg model =
    case ( msg, model.room ) of
        ( ReceiveUpdate room, Just prevRoom ) ->
            let
                isHost =
                    room.host == model.playerId

                isNewRound =
                    Maybe.map2 (\newRound oldRound -> newRound.no /= oldRound.no) room.round prevRoom.round |> Maybe.withDefault True

                allPlayersReady =
                    Room.allPlayersReady room

                prevAllPlayersReady =
                    Room.allPlayersReady prevRoom

                resetTime =
                    isNewRound || (allPlayersReady && (not prevAllPlayersReady))

                initiateNewRound =
                    isHost && allPlayersReady && (room.round == Nothing)
            in
                ( { model
                    | room = Just room
                    , time =
                        if resetTime then
                            RoundTime.init
                        else
                            model.time
                  }
                , []
                , initiateNewRound
                )

        ( ReceiveUpdate room, Nothing ) ->
            ( { model | room = Just room }, [], False )

        ( ReceiveNewProblem problem, Just room ) ->
            let
                newRound =
                    room.round
                        |> Maybe.map
                            (\round ->
                                { no = round.no + 1
                                , problem = problem
                                }
                            )
                        |> Maybe.withDefault
                            { no = 0
                            , problem = problem
                            }
                        |> Just

                newRoom =
                    { room
                        | round = newRound
                        , players = Dict.map (\playerId player -> { player | guess = Nothing }) room.players
                    }

                newModel =
                    { model
                        | room = Just newRoom
                        , time = RoundTime.init
                    }
            in
                ( newModel
                , [ updateRoomCmd spec newModel ] |> List.filterMap identity
                , False
                )

        ( ReceiveNewProblem problem, Nothing ) ->
            -- Impossible state
            ( model, [], False )

        ( Guess guess, Just room ) ->
            let
                isRoundOver =
                    RoundTime.timeSinceNewRound model.time > spec.roundDuration

                newModel =
                    setOwnGuess guess model

                newPlayer =
                    getOwnPlayer newModel
            in
                if isRoundOver then
                    ( model, [], False )
                else
                    ( newModel, [ updatePlayerCmd spec newPlayer ] |> List.filterMap identity, False )

        ( Guess guess, Nothing ) ->
            -- Impossible state
            ( model, [], False )

        ( MarkReady, Just room ) ->
            let
                newRoom =
                    room
                        |> (Room.updatePlayer
                                (\pl -> { pl | isReady = not pl.isReady })
                                model.playerId
                           )

                newModel =
                    { model
                        | room = Just newRoom
                        , time = RoundTime.init
                    }
            in
                ( newModel
                , [ updateRoomCmd spec newModel ] |> List.filterMap identity
                , False
                )

        ( MarkReady, Nothing ) ->
            -- Impossible state
            ( model, [], False )

        ( Tick time, Just room ) ->
            let
                potentialRoundWinner =
                    Room.getRoundWinner spec room

                allPlayersReady =
                    Room.allPlayersReady room

                isHost =
                    room.host == model.playerId

                newTime =
                    RoundTime.update time model.time

                isRoundJustOver =
                    RoundTime.justPassed
                        spec.roundDuration
                        model.time
                        newTime

                isCooldownJustOver =
                    RoundTime.justPassed
                        (spec.roundDuration + spec.cooldownDuration)
                        model.time
                        newTime

                initiateNewRound =
                    isHost
                        && ((room.round == Nothing) || isCooldownJustOver)

                ( newRoom, isScoreSet ) =
                    if (isHost && isRoundJustOver) then
                        (case potentialRoundWinner of
                            Just winnerId ->
                                ( if room.host == model.playerId then
                                    Room.setScores (Just winnerId) room
                                  else
                                    room
                                , True
                                )

                            Nothing ->
                                ( if room.host == model.playerId then
                                    Room.setScores Nothing room
                                  else
                                    room
                                , True
                                )
                        )
                    else
                        ( room, False )

                newModel =
                    { model
                        | room =
                            Just newRoom
                        , time =
                            if allPlayersReady then
                                RoundTime.update time model.time
                            else
                                model.time
                    }
            in
                ( newModel
                , [ if isScoreSet then
                        updateRoomCmd spec newModel
                    else
                        Nothing
                  ]
                    |> List.filterMap identity
                , initiateNewRound
                )

        ( Tick time, Nothing ) ->
            ( model
            , []
            , False
            )
