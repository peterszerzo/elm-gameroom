module Gameroom.Views.Home exposing (..)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Html.Events exposing (onClick, onInput)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Views.Styles as Styles


view : Html (Msg problemType guessType)
view =
    div [ style Styles.centered ]
        [ h1 [] [ text "elm-gameroom" ]
        , button [ onClick (Navigate "/tutorial") ] [ text "Tutorial" ]
        , button [ onClick (Navigate "/new") ] [ text "New room" ]
        ]
