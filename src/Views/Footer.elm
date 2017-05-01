module Views.Footer exposing (..)

import Html exposing (Html, div, footer)
import Html.CssHelpers
import Css exposing (position, fixed, px, right, bottom, pct, width, overflowY, visible)
import Css.Namespace exposing (namespace)


cssNamespace : String
cssNamespace =
    "footer"


type CssClasses
    = Root


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Css.Snippet
styles =
    [ Css.class Root
        [ position fixed
        , right (px 0)
        , bottom (px 0)
        , width (pct 100)
        , overflowY visible
        ]
    ]
        |> namespace cssNamespace


view : List (Html msg) -> Html msg
view children =
    div
        [ class [ Root ]
        ]
        children
