module Models.Game exposing (..)

import Dict
import Constants
import Gameroom.Spec as Spec
import Models.Guess exposing (Guess)
import Models.Room as Room
import Models.RoundTime as RoundTime
import Models.RoomId exposing (RoomId)
import Models.Player exposing (Player, PlayerId)


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


getNotificationContent : Spec.Spec problem guess -> Game problem guess -> Maybe String
getNotificationContent spec model =
    case model.room of
        Just room ->
            if (RoundTime.timeSinceNewRound model.time < Constants.roundDuration) then
                Maybe.map2
                    (\guess round ->
                        if spec.isGuessCorrect round.problem guess.value then
                            "Good job. Now let's see if you were the fastest.."
                        else
                            "Not quite correct that one.."
                    )
                    (getOwnGuess model)
                    room.round
            else
                Room.getRoundWinner spec room
                    |> Maybe.map
                        (\winnerId ->
                            if winnerId == model.playerId then
                                "Nice job, you win!"
                            else
                                "This one goes to " ++ winnerId ++ ". Go get them in the next round!"
                        )
                    |> Maybe.withDefault "It's a tie, folks, it's a tie.."
                    |> Just

        Nothing ->
            Nothing
