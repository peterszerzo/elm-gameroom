module Update.Game exposing (..)

import Dict
import Messages exposing (..)
import Models.Room as Room
import Models.Game exposing (Game)
import Models.Spec exposing (Spec)
import Json.Decode as JD


update :
    Spec problemType guessType
    -> Messages.GameMsg problemType guessType
    -> Game problemType guessType
    -> Game problemType guessType
update spec msg model =
    case msg of
        ReceiveUpdate roomString ->
            { model
                | room =
                    roomString
                        |> JD.decodeString (Room.decoder spec.problemDecoder spec.guessDecoder)
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
