module Views exposing (view)

import Dict
import Html exposing (Html, div, text, button, h1)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Models.Main exposing (Model)
import Models.Spec exposing (Spec)
import Models.Room exposing (Room)
import Messages exposing (Msg(..))
import Router


scoreboard : String -> Room problemType guessType -> Html (Msg problemType guessType)
scoreboard playerId room =
    div [ class "scoreboard" ]
        [ Dict.get playerId room.players
            |> Maybe.map (text << toString << .score)
            |> Maybe.withDefault (text "noscore")
        ]


home : Html (Msg problemType guessType)
home =
    div []
        [ h1 [] [ text "Hello" ]
        , button [ onClick (Navigate "/tutorial") ] [ text "Tutorial" ]
        , button [ onClick (Navigate "/new") ] [ text "New room" ]
        ]


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec model =
    let
        content =
            case model.route of
                Router.Game roomId playerId maybeRoom ->
                    maybeRoom
                        |> Maybe.map (Html.map Guess << spec.view playerId)
                        |> Maybe.withDefault (div [] [])

                Router.Home ->
                    home

                _ ->
                    div [] []
    in
        div [ class "container" ]
            [ content
            ]
