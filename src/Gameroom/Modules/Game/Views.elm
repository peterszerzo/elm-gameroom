module Gameroom.Modules.Game.Views exposing (..)

import Dict
import Html exposing (Html, div, text, p, table, tr, td)
import Html.Attributes exposing (class, style)
import Gameroom.Modules.Game.Models exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Models.Room exposing (Room)
import Gameroom.Modules.Game.Messages exposing (Msg(..))


scoreboard : String -> Room problemType guessType -> Html msg
scoreboard playerId room =
    div
        [ style
            [ ( "position", "fixed" )
            , ( "right", "80px" )
            , ( "bottom", "80px" )
            , ( "padding", "20px" )
            , ( "background", "#eee" )
            ]
        ]
        [ room.players
            |> Dict.toList
            |> List.map
                (\( playerId, player ) ->
                    tr []
                        [ td [] [ (text player.id) ]
                        , td [] [ (text (toString player.score)) ]
                        ]
                )
            |> (\list -> table [] list)
        ]


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec game =
    case game.room of
        Just room ->
            div []
                [ Html.map Guess (spec.view game.playerId room)
                , scoreboard game.playerId room
                ]

        Nothing ->
            div []
                [ text "Loading" ]
