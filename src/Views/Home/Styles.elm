module Views.Home.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins
import Styles.Constants exposing (..)


cssNamespace : String
cssNamespace =
    "home"


type CssClasses
    = Root
    | Logo
    | Link


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Root Mixins.centered
    , class Logo
        [ width (px 80)
        , height (px 80)
        , margin auto
        , border3 (px 1) solid (hex white)
        ]
    , class Link Mixins.button
    ]
        |> namespace cssNamespace
