module Update.Game exposing (..)

import Random
import Dict
import Commands as Commands
import Messages exposing (..)
import Models.Room as Room
import Models.Player as Player
import Gameroom.Spec exposing (Spec)
import Models.Ports exposing (Ports)
import Models.Game as Game
import Models.Result as Result
import Json.Encode as JE


updateRoomCmd :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Game.Game problem guess
    -> Cmd (Messages.Msg problem guess)
updateRoomCmd spec ports model =
    model.room
        |> Maybe.map (Commands.UpdateRoom >> (Commands.commandEncoder spec.problemEncoder spec.guessEncoder) >> JE.encode 0 >> ports.outgoing)
        |> Maybe.withDefault Cmd.none


updatePlayerCmd :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Maybe (Player.Player guess)
    -> Cmd (Messages.Msg problem guess)
updatePlayerCmd spec ports player =
    player
        |> Maybe.map (Commands.UpdatePlayer >> (Commands.commandEncoder spec.problemEncoder spec.guessEncoder) >> JE.encode 0 >> ports.outgoing)
        |> Maybe.withDefault Cmd.none


update :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> GameMsg problem guess
    -> Game.Game problem guess
    -> ( Game.Game problem guess, Cmd (Messages.Msg problem guess) )
update spec ports msg model =
    case msg of
        ReceiveUpdate room ->
            let
                result =
                    Result.get spec room

                newProblemCmd =
                    if (room.host == model.playerId) then
                        (Random.generate (\pb -> Messages.GameMsg (ReceiveNewProblem pb)) spec.problemGenerator)
                    else
                        Cmd.none

                ( newRoom, cmd ) =
                    case result of
                        Result.Pending ->
                            ( room
                            , if room.round.problem == Nothing then
                                newProblemCmd
                              else
                                Cmd.none
                            )

                        Result.Winner winnerId ->
                            ( if room.host == model.playerId then
                                Room.setNewRound (Just winnerId) room
                              else
                                room
                            , newProblemCmd
                            )

                        Result.Tie ->
                            ( if room.host == model.playerId then
                                Room.setNewRound Nothing room
                              else
                                room
                            , newProblemCmd
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
                    updateRoomCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        Guess guess ->
            let
                newGuess =
                    Just { value = guess, madeAt = model.ticksSinceNewRound }

                player =
                    model.room
                        |> Maybe.map .players
                        |> Maybe.andThen (Dict.get model.playerId)
                        |> Maybe.map (\pl -> { pl | guess = newGuess })

                newModel =
                    { model
                        | room =
                            model.room
                                |> Maybe.map2
                                    (\player room ->
                                        { room
                                            | players = Dict.insert model.playerId player room.players
                                        }
                                    )
                                    player
                    }

                cmd =
                    updatePlayerCmd spec ports player
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
                    updateRoomCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        Tick time ->
            ( { model
                | ticksSinceNewRound =
                    model.ticksSinceNewRound + 1
              }
            , Cmd.none
            )
