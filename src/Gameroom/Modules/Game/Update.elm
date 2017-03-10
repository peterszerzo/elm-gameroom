module Gameroom.Modules.Game.Update exposing (..)

import Random
import Json.Encode as JE
import Gameroom.Messages as Messages
import Gameroom.Models.Room as Room
import Gameroom.Spec exposing (Spec)
import Gameroom.Ports exposing (Ports)
import Gameroom.Models.Result as Result
import Gameroom.Modules.Game.Messages exposing (Msg(..))
import Gameroom.Modules.Game.Models exposing (Model)
import Json.Decode as JD


saveCmd : Spec problem guess -> Ports (Messages.Msg problem guess) -> Model problem guess -> Cmd (Messages.Msg problem guess)
saveCmd spec ports model =
    model.room |> Maybe.map (ports.updateRoom << JE.encode 0 << Room.encoder spec.problemEncoder spec.guessEncoder) |> Maybe.withDefault Cmd.none


update :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Messages.Msg problem guess) )
update spec ports msg model =
    case msg of
        ReceiveUpdate roomString ->
            let
                newRoom_ =
                    roomString
                        |> JD.decodeString (Room.decoder spec.problemDecoder spec.guessDecoder)
                        |> Result.toMaybe

                result =
                    newRoom_ |> Maybe.map (Result.get spec)

                newProblemCmd =
                    Maybe.withDefault Cmd.none
                        << Maybe.map
                            (\room ->
                                if (room.host == model.playerId |> Debug.log "ishost") then
                                    (Random.generate (\pb -> Messages.GameMsgC (ReceiveNewProblem pb)) spec.problemGenerator)
                                else
                                    Cmd.none
                            )

                ( newRoom, cmd ) =
                    case result of
                        Just (Result.Pending) ->
                            ( newRoom_
                            , if (newRoom_ |> Maybe.andThen (.problem << .round)) == Nothing then
                                newProblemCmd newRoom_
                              else
                                Cmd.none
                            )

                        Just (Result.Winner winnerId) ->
                            ( newRoom_ |> Maybe.map (Room.setNewRound (Just winnerId)), newProblemCmd newRoom_ )

                        Just (Result.Tie) ->
                            ( newRoom_ |> Maybe.map (Room.setNewRound Nothing), Cmd.none )

                        _ ->
                            ( newRoom_, Cmd.none )
            in
                ( { model
                    | room =
                        newRoom
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
            ( { model | roundTime = model.roundTime + 1 }, Cmd.none )
