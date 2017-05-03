module Models.Result exposing (..)

import Dict
import Gameroom.Spec as Spec
import Models.Room as Room


bigNumber : Int
bigNumber =
    100000


type Result
    = Pending
    | Winner String
    | Tie


get : Spec.Spec problem guess -> Room.Room problem guess -> Result
get spec room =
    room.players
        |> Dict.toList
        |> List.map
            (\( playerId, player ) ->
                ( playerId
                , player.guess |> Maybe.map .madeAt |> Maybe.withDefault bigNumber
                , player.guess
                    |> Maybe.map2 (\round guess -> spec.isGuessCorrect round.problem guess.value) room.round
                    |> Maybe.withDefault False
                )
            )
        |> List.filter (\( playerId, madeAt, isCorrect ) -> isCorrect)
        |> List.sortBy (\( playerId, madeAt, isCorrect ) -> madeAt)
        |> List.head
        |> Maybe.map (\( playerId, _, _ ) -> Winner playerId)
        |> Maybe.withDefault Pending
