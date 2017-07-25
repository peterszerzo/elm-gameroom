module Page.Game.Helpers exposing (..)

import Data.Spec as Spec
import Page.Game.Models exposing (Model, getOwnGuess)
import Data.Room as Room
import Data.RoundTime as RoundTime
import Copy
import Utils


getNotificationContent : Spec.DetailedSpec problem guess -> Model problem guess -> Maybe String
getNotificationContent spec model =
    let
        roundTime =
            RoundTime.timeSinceNewRound model.time
    in
        case model.room of
            Just room ->
                if (roundTime < spec.roundDuration) then
                    Maybe.map2
                        (\guess round ->
                            let
                                eval =
                                    spec.evaluate round.problem guess.value
                            in
                                case spec.clearWinnerEvaluation of
                                    Just clearWinnerEval ->
                                        if eval == clearWinnerEval then
                                            Copy.correctGuess
                                        else
                                            Copy.incorrectGuess

                                    Nothing ->
                                        Utils.template Copy.evaluatedGuess (toString eval)
                        )
                        (getOwnGuess model)
                        room.round
                else
                    Room.getRoundWinner spec.evaluate spec.clearWinnerEvaluation room
                        |> Maybe.map
                            (\winnerId ->
                                if winnerId == model.playerId then
                                    Copy.win
                                else
                                    Utils.template Copy.lose winnerId
                            )
                        |> Maybe.withDefault Copy.tie
                        |> Just

            Nothing ->
                Nothing
