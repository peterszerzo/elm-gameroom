module Models.Game exposing (..)

import Dict
import Models.Spec as Spec
import Models.Guess exposing (Guess)
import Models.Room as Room
import Models.RoundTime as RoundTime
import Models.RoomId exposing (RoomId)
import Models.Player exposing (Player, PlayerId)
import Constants
import Utils


type alias Game problem guess =
    { roomId : String
    , playerId : String
    , room : Maybe (Room.Room problem guess)
    , time : RoundTime.RoundTime
    }



-- Helpers


init : RoomId -> PlayerId -> Game problem guess
init roomId playerId =
    { roomId = roomId
    , playerId = playerId
    , room = Nothing
    , time = RoundTime.init
    }


isHost : Game problem guess -> Bool
isHost game =
    game.room
        |> Maybe.map (\room -> room.host == game.playerId)
        |> Maybe.withDefault False


setOwnGuess : guess -> Game problem guess -> Game problem guess
setOwnGuess guess model =
    case model.room of
        Just room ->
            let
                newGuess =
                    Just { value = guess, madeAt = RoundTime.timeSinceNewRound model.time }

                players =
                    room.players
                        |> Dict.map
                            (\playerId player ->
                                if playerId == model.playerId then
                                    { player | guess = newGuess }
                                else
                                    player
                            )

                newRoom =
                    { room | players = players }
            in
                { model | room = Just newRoom }

        Nothing ->
            model


getOwnPlayer : Game problem guess -> Maybe (Player guess)
getOwnPlayer model =
    model.room
        |> Maybe.map .players
        |> Maybe.andThen (Dict.get model.playerId)


getOwnGuess : Game problem guess -> Maybe (Guess guess)
getOwnGuess model =
    getOwnPlayer model
        |> Maybe.andThen .guess


getNotificationContent : Spec.DetailedSpec problem guess -> Game problem guess -> Maybe String
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
                                            Constants.correctGuessCopy
                                        else
                                            Constants.incorrectGuessCopy

                                    Nothing ->
                                        Constants.evaluatedGuessCopy
                                            |> Utils.template (toString eval)
                        )
                        (getOwnGuess model)
                        room.round
                else
                    Room.getRoundWinner spec room
                        |> Maybe.map
                            (\winnerId ->
                                if winnerId == model.playerId then
                                    Constants.winCopy
                                else
                                    Constants.loseCopy |> Utils.template winnerId
                            )
                        |> Maybe.withDefault Constants.tieCopy
                        |> Just

            Nothing ->
                Nothing
