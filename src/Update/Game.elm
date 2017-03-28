module Update.Game exposing (..)

import Random
import Json.Encode as JE
import Gameroom.Spec exposing (Spec)
import Constants as Consts
import Commands
import Messages.Main as Messages
import Models.Room as Room
import Models.Game as Game
import Models.Ports exposing (Ports)
import Models.Result as Result
import Messages.Game exposing (Msg(..))
import Models.Game exposing (Game)


saveCmd :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Game.Game problem guess
    -> Cmd (Messages.Msg problem guess)
saveCmd spec ports model =
    model.room
        |> Maybe.map (Commands.UpdateRoom >> (Commands.commandEncoder spec.problemEncoder spec.guessEncoder) >> JE.encode 0 >> ports.outgoing)
        |> Maybe.withDefault Cmd.none


update :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Msg problem guess
    -> Game problem guess
    -> ( Game problem guess, Cmd (Messages.Msg problem guess) )
update spec ports msg model =
    case msg of
        ReceiveUpdate room ->
            let
                result =
                    Result.get spec room

                newProblemCmd =
                    if (room.host == model.playerId) then
                        (Random.generate (\pb -> Messages.GameMsgC (ReceiveNewProblem pb)) spec.problemGenerator)
                    else
                        Cmd.none

                ( newRoom, cmd ) =
                    case result of
                        Result.Pending ->
                            ( room
                            , if room.round.problem == Nothing then
                                Debug.log "newprob req" newProblemCmd
                              else
                                Cmd.none
                            )

                        Result.Winner winnerId ->
                            ( if room.host == model.playerId then
                                Room.setNewRound (Just winnerId) room
                              else
                                room
                            , Debug.log "newprob req" newProblemCmd
                            )

                        Result.Tie ->
                            ( if room.host == model.playerId then
                                Room.setNewRound Nothing room
                              else
                                room
                            , Debug.log "newprob req" newProblemCmd
                            )
            in
                ( { model
                    | room =
                        Just newRoom
                  }
                , cmd
                )

        ReceiveNewProblem problem ->
            let
                _ =
                    Debug.log "newprob" "receiving"

                newRoom =
                    model.room
                        |> Maybe.map
                            (\rm ->
                                let
                                    oldRound =
                                        rm.round

                                    newRound =
                                        { oldRound | problem = Just problem }
                                in
                                    { rm | round = newRound }
                            )

                newModel =
                    { model | room = newRoom }

                cmd =
                    saveCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        Guess guess ->
            let
                newModel =
                    { model
                        | room =
                            model.room
                                |> Maybe.map
                                    (Room.updatePlayer (\pl -> { pl | guess = Just { value = guess, madeAt = model.roundTime } }) model.playerId)
                    }

                cmd =
                    saveCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        MarkReady ->
            let
                newRoom =
                    model.room
                        |> Maybe.map
                            (Room.updatePlayer (\pl -> { pl | isReady = True }) model.playerId)

                newModel =
                    { model | room = newRoom }

                cmd =
                    saveCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        Tick time ->
            ( { model
                | roundTime =
                    model.roundTime + Consts.gameTick
              }
            , Cmd.none
            )
