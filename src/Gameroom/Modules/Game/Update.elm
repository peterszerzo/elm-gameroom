module Gameroom.Modules.Game.Update exposing (..)

import Dict
import Random
import Json.Encode as JE
import Gameroom.Ports as Ports
import Gameroom.Messages as Messages
import Gameroom.Models.Room as Room
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Modules.Game.Messages exposing (Msg(..))
import Gameroom.Modules.Game.Models exposing (Model)
import Json.Decode as JD


update :
    Spec problemType guessType
    -> Msg problemType guessType
    -> Model problemType guessType
    -> ( Model problemType guessType, Cmd (Messages.Msg problemType guessType) )
update spec msg model =
    case msg of
        ReceiveUpdate roomString ->
            let
                newRoom =
                    roomString
                        |> JD.decodeString (Room.decoder spec.problemDecoder spec.guessDecoder)
                        |> Result.toMaybe

                cmd =
                    newRoom
                        |> Maybe.map
                            (\room ->
                                if room.host == model.playerId then
                                    (Random.generate (\pb -> Messages.GameMsgContainer (ReceiveNewProblem pb)) spec.problemGenerator)
                                else
                                    Cmd.none
                            )
                        |> Maybe.withDefault Cmd.none
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

                cmd =
                    newRoom |> Maybe.map (Ports.updateRoom << JE.encode 0 << Room.encoder spec.problemEncoder spec.guessEncoder) |> Maybe.withDefault Cmd.none
            in
                ( { model
                    | room =
                        newRoom
                  }
                , cmd
                )

        Guess guess ->
            ( { model
                | room =
                    model.room
                        |> Maybe.map
                            (\rm ->
                                { rm
                                    | players =
                                        Dict.update model.playerId
                                            (Maybe.map (\player -> { player | guess = Just { value = guess, madeAt = model.roundTime } }))
                                            rm.players
                                }
                            )
              }
            , Cmd.none
            )

        Tick time ->
            ( { model | roundTime = model.roundTime + 1 }, Cmd.none )
