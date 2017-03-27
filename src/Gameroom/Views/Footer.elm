module Gameroom.Views.Footer exposing (view)

import Html exposing (Html, div, footer)
import Html.Attributes exposing (style)


view : List (Html msg) -> Html msg
view children =
    div
        [ style
            [ ( "position", "fixed" )
            , ( "right", "0" )
            , ( "bottom", "0" )
            , ( "width", "100%" )
            , ( "overflow", "visible" )
            ]
        ]
        children
