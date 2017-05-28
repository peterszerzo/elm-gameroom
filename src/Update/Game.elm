module Update.Game exposing (..)

import Random
import Dict
import Models.OutgoingMessage as OutgoingMessage
import Constants
import Messages exposing (..)
import Models.Game
import Models.Room as Room
import Models.Player as Player
import Gameroom.Spec exposing (Spec)
import Models.Ports exposing (Ports)
import Models.Game as Game


updateRoomCmd :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Game.Game problem guess
    -> Cmd (Messages.Msg problem guess)
updateRoomCmd spec ports model =
    model.room
        |> Maybe.map (OutgoingMessage.UpdateRoom >> (OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder) >> ports.outgoing)
        |> Maybe.withDefault Cmd.none


updatePlayerCmd :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Maybe (Player.Player guess)
    -> Cmd (Messages.Msg problem guess)
updatePlayerCmd spec ports player =
    player
        |> Maybe.map (OutgoingMessage.UpdatePlayer >> (OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder) >> ports.outgoing)
        |> Maybe.withDefault Cmd.none


update :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> GameMsg problem guess
    -> Game.Game problem guess
    -> ( Game.Game problem guess, Cmd (Messages.Msg problem guess) )
update spec ports msg model =
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

                resetTicks =
                    isNewRound || (allPlayersReady && (not prevAllPlayersReady))

                newProblemCmd =
                    (Random.generate (\pb -> Messages.GameMsg (ReceiveNewProblem pb)) spec.problemGenerator)

                initiateNewRound =
                    isHost && allPlayersReady && (room.round == Nothing)
            in
                ( { model
                    | room = Just room
                    , ticksSinceNewRound =
                        if resetTicks then
                            0
                        else
                            model.ticksSinceNewRound
                    , animationTicksSinceNewRound =
                        if resetTicks then
                            0
                        else
                            model.animationTicksSinceNewRound
                  }
                , if initiateNewRound then
                    newProblemCmd
                  else
                    Cmd.none
                )

        ( ReceiveUpdate room, Nothing ) ->
            ( { model | room = Just room }, Cmd.none )

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
                        , ticksSinceNewRound = 0
                        , animationTicksSinceNewRound = 0
                    }

                cmd =
                    updateRoomCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        ( ReceiveNewProblem problem, Nothing ) ->
            -- Impossible state
            ( model, Cmd.none )

        ( Guess guess, Just room ) ->
            let
                didAlreadyGuess =
                    Game.getOwnGuess model /= Nothing

                isRoundOver =
                    model.ticksSinceNewRound > Constants.ticksInRound

                newModel =
                    Models.Game.setOwnGuess guess model

                newPlayer =
                    Models.Game.getOwnPlayer newModel

                cmd =
                    updatePlayerCmd spec ports newPlayer
            in
                if didAlreadyGuess || isRoundOver then
                    ( model, Cmd.none )
                else
                    ( newModel, cmd )

        ( Guess guess, Nothing ) ->
            -- Impossible state
            ( model, Cmd.none )

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
                        , ticksSinceNewRound = 0
                        , animationTicksSinceNewRound = 0
                    }

                cmd =
                    updateRoomCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        ( MarkReady, Nothing ) ->
            -- Impossible state
            ( model, Cmd.none )

        ( AnimationTick time, _ ) ->
            ( { model
                | animationTicksSinceNewRound =
                    model.animationTicksSinceNewRound + 1
              }
            , Cmd.none
            )

        ( Tick time, Just room ) ->
            let
                potentialRoundWinner =
                    Room.getRoundWinner spec room

                newProblemCmd =
                    (Random.generate (\pb -> Messages.GameMsg (ReceiveNewProblem pb)) spec.problemGenerator)

                allPlayersReady =
                    Room.allPlayersReady room

                isHost =
                    room.host == model.playerId

                isRoundJustOver =
                    (model.ticksSinceNewRound == Constants.ticksInRound)

                isCooldownJustOver =
                    (model.ticksSinceNewRound == (Constants.ticksInRound + Constants.ticksInCooldown))

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
                        , ticksSinceNewRound =
                            model.ticksSinceNewRound
                                + (if allPlayersReady then
                                    1
                                   else
                                    0
                                  )
                    }
            in
                ( newModel
                , Cmd.batch
                    [ if initiateNewRound then
                        newProblemCmd
                      else
                        Cmd.none
                    , if isScoreSet then
                        updateRoomCmd spec ports newModel
                      else
                        Cmd.none
                    ]
                )

        ( Tick time, Nothing ) ->
            ( model
            , Cmd.none
            )
