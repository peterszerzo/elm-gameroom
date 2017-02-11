module Views.UiKit exposing (..)

import Dict
import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Models.Room exposing (Room)
import Messages exposing (Msg(..), NewRoomMsg(..))


scoreboard : String -> Room problemType guessType -> Html (Msg problemType guessType)
scoreboard playerId room =
    div [ class "scoreboard" ]
        [ Dict.get playerId room.players
            |> Maybe.map (text << toString << .score)
            |> Maybe.withDefault (text "noscore")
        ]
