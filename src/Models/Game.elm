module Models.Game exposing (..)

import Dict
import Models.Room exposing (Room)
import Models.Player exposing (Player)


type alias Game problem guess =
    { roomId : String
    , playerId : String
    , room : Maybe (Room problem guess)
    , ticksSinceNewRound : Int
    , ticksToNewRound : Maybe Int
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
