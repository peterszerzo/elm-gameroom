module Gameroom.Models.Result exposing (..)

import Dict
import Gameroom.Models.Room as Room
import Gameroom.Models.Spec as Spec


type Result
    = Pending
    | Winner String
    | Tie


get : Spec.Spec problemType guessType -> Room.Room problemType guessType -> Result
get spec room =
    room.players
        |> Dict.toList
        |> List.map
            (\( playerId, player ) ->
                ( playerId
                , player.guess
                    |> Maybe.map2 (\problem guessWithTimestamp -> spec.isGuessCorrect problem guessWithTimestamp.value) room.round.problem
                    |> Maybe.withDefault False
                )
            )
        |> List.filter (\( playerId, isCorrect ) -> isCorrect)
        |> List.head
        |> Maybe.map (\( playerId, isCorrect ) -> Winner playerId)
        |> Maybe.withDefault Pending
