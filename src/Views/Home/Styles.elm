module Views.Home.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "home"


type CssClasses
    = Root
    | Logo
    | Title
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
        ]
    , class Title Mixins.heroType
    , class Link Mixins.button
    ]
        |> namespace cssNamespace
