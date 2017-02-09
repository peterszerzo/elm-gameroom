module Views exposing (view)

import Dict
import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Models.Main exposing (Model)
import Models.Spec exposing (Spec)
import Models.Room exposing (Room)
import Messages exposing (Msg(..))


scoreboard : String -> Room problemType guessType -> Html (Msg problemType guessType)
scoreboard playerId room =
    div [ class "scoreboard" ]
        [ Dict.get playerId room.players
            |> Maybe.map (text << toString << .score)
            |> Maybe.withDefault (text "noscore")
        ]


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec model =
    let
        gameView =
            case model.room of
                Just room ->
                    spec.view model.playerId room |> Html.map Guess

                Nothing ->
                    div [] []
    in
        div [ class "container" ]
            [ button [ onClick (Navigate "/tutorial") ] [ text "hello!" ]
            , gameView
            ]
