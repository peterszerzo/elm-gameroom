module Page.Game.Models exposing (..)

import Dict
import Data.Guess exposing (Guess)
import Data.Room as Room
import Data.RoundTime as RoundTime
import Data.Player as Player


type alias Model problem guess =
    { roomId : Room.RoomId
    , playerId : Player.PlayerId
    , room : Maybe (Room.Room problem guess)
    , time : RoundTime.RoundTime
    }



-- Helpers


init : Room.RoomId -> Player.PlayerId -> Model problem guess
init roomId playerId =
    { roomId = roomId
    , playerId = playerId
    , room = Nothing
    , time = RoundTime.init
    }


isHost : Model problem guess -> Bool
isHost game =
    game.room
        |> Maybe.map (\room -> room.host == game.playerId)
        |> Maybe.withDefault False


setOwnGuess : guess -> Model problem guess -> Model problem guess
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


getOwnPlayer : Model problem guess -> Maybe (Player.Player guess)
getOwnPlayer model =
    model.room
        |> Maybe.map .players
        |> Maybe.andThen (Dict.get model.playerId)


getOwnGuess : Model problem guess -> Maybe (Guess guess)
getOwnGuess model =
    getOwnPlayer model
        |> Maybe.andThen .guess
