module Gameroom.Modules.Game.Views exposing (..)

import Gameroom.Modules.Game.Models exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Messages exposing (..)
import Html exposing (Html, div)


view : Spec problemType guessType -> Model problemType guessType -> Html (GameMsg problemType guessType)
view spec game =
    game.room
        |> Maybe.map (Html.map Guess << spec.view game.playerId)
        |> Maybe.withDefault (div [] [])
