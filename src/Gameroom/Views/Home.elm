module Gameroom.Views.Home exposing (..)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for, href)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Views.Styles as Styles
import Gameroom.Views.Link as Link
import Gameroom.Views.Logo as Logo
import Gameroom.Views.Styles as Styles


view : Html (Msg problemType guessType)
view =
    div [ style Styles.centered ]
        [ div [ style [ ( "width", "100px" ), ( "height", "100px" ), ( "margin", "auto" ) ] ] [ Logo.view ]
        , h1 [ style Styles.heroType ] [ text "elm-gameroom" ]
        , Link.view [ href "/tutorial" ] [ text "Tutorial" ]
        , Link.view [ href "/new" ] [ text "New room" ]
        ]
