module Gameroom.Modules.Game.Views exposing (..)

import Dict
import Html exposing (Html, div, text, p, table, tr, td, h2, ul, li, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Gameroom.Modules.Game.Models exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Models.Room as Room
import Gameroom.Modules.Game.Messages exposing (Msg(..))
import Gameroom.Views.Styles as Styles


scoreboard : String -> Room.Room problemType guessType -> Html msg
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


viewReadyPrompt : Spec problemType guessType -> Model problemType guessType -> Room.Room problemType guessType -> Html (Msg problemType guessType)
viewReadyPrompt spec model room =
    div [ style Styles.centered ]
        [ h2 [] [ text "Ready?" ]
        , ul []
            (room.players
                |> Dict.toList
                |> List.map Tuple.second
                |> List.map
                    (\pl ->
                        li []
                            [ span
                                ([]
                                    ++ (if room.host == pl.id then
                                            [ onClick MarkReady ]
                                        else
                                            []
                                       )
                                )
                                [ text pl.id ]
                            ]
                    )
            )
        ]


viewRoom : Spec problemType guessType -> Model problemType guessType -> Room.Room problemType guessType -> Html (Msg problemType guessType)
viewRoom spec model room =
    div []
        [ if Room.allPlayersReady room then
            Html.map Guess (spec.view model.playerId room)
          else
            viewReadyPrompt spec model room
        , scoreboard model.playerId room
        ]


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec model =
    case model.room of
        Just room ->
            viewRoom spec model room

        Nothing ->
            div [ style Styles.centered ]
                [ text "Loading" ]
