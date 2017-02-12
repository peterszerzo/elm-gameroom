module Views.Game exposing (..)

import Models.Game exposing (Game)
import Models.Spec exposing (Spec)
import Messages exposing (..)
import Html exposing (Html, div)


view : Spec problemType guessType -> Game problemType guessType -> Html (GameMsg problemType guessType)
view spec game =
    game.room
        |> Maybe.map (Html.map Guess << spec.view game.playerId)
        |> Maybe.withDefault (div [] [])
