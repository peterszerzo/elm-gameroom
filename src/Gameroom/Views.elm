module Views exposing (view)

import Dict
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Models exposing (Model, Spec, Room)
import Messages exposing (Msg(..))


scoreboard : String -> Room problemType guessType -> Html (Msg guessType)
scoreboard playerId room =
    div [ class "scoreboard" ]
        [ Dict.get playerId room.players
            |> Maybe.map (text << toString << .score)
            |> Maybe.withDefault (text "noscore")
        ]


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg guessType)
view spec model =
    let
        gameView =
            case model.room of
                Just room ->
                    spec.view model.playerId room |> Html.map Guess

                Nothing ->
                    div [] []
    in
        div []
            [ gameView
            ]
