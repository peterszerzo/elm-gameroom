module Gameroom.Modules.Game.Update exposing (..)

import Dict
import Gameroom.Models.Room as Room
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Modules.Game.Messages exposing (Msg(..))
import Gameroom.Modules.Game.Models exposing (Model)
import Json.Decode as JD


update :
    Spec problemType guessType
    -> Msg problemType guessType
    -> Model problemType guessType
    -> Model problemType guessType
update spec msg model =
    case msg of
        ReceiveUpdate roomString ->
            { model
                | room =
                    roomString
                        |> JD.decodeString (Room.decoder spec.problemDecoder spec.guessDecoder)
                        |> Debug.log "a"
                        |> Result.toMaybe
            }

        ReceiveNewProblem problem ->
            { model
                | room =
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
            }

        Guess guess ->
            { model
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

        Tick time ->
            { model | roundTime = model.roundTime + 1 }
