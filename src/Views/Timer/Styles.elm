module Views.Timer.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Constants exposing (..)


cssNamespace : String
cssNamespace =
    "timer"


type CssClasses
    = Root


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Root
        [ position absolute
        , top (px 0)
        , width (pct 100)
        , height (px 1)
        , left (px 0)
        , backgroundColor (hex lightBlue)
        , property "transition" "transform 0.3s"
        ]
    ]
        |> namespace cssNamespace
