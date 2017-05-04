module Models.Game exposing (..)

import Dict
import Constants
import Gameroom.Spec as Spec
import Models.Guess exposing (Guess)
import Models.Room as Room
import Models.Player exposing (Player)


type alias Game problem guess =
    { roomId : String
    , playerId : String
    , room : Maybe (Room.Room problem guess)
    , ticksSinceNewRound : Int
    }



-- Helpers


setOwnGuess : guess -> Game problem guess -> Game problem guess
setOwnGuess guess model =
    case model.room of
        Just room ->
            let
                newGuess =
                    Just { value = guess, madeAt = model.ticksSinceNewRound }

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


getNotificationContent : Spec.Spec problem guess -> Game problem guess -> Maybe String
getNotificationContent spec model =
    case model.room of
        Just room ->
            if (model.ticksSinceNewRound < Constants.ticksInRound) then
                Maybe.map2
                    (\guess round ->
                        if spec.isGuessCorrect round.problem guess.value then
                            "Correct - see if you were faster :)"
                        else
                            "Better luck next time.."
                    )
                    (getOwnGuess model)
                    room.round
            else
                Room.getRoundWinner spec room
                    |> Maybe.map (\s -> "This one goes to " ++ s)
                    |> Maybe.withDefault "It's a tie, folks.."
                    |> Just

        Nothing ->
            Nothing
