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
    | Subheading
    | Nav


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
        , fontSize (px 60)
        ]
    , class Link Mixins.button
    , class Subheading [ fontSize (Css.rem 1.25), margin2 (px 10) auto ]
    , class Nav [ marginTop (px 30) ]
    ]
        |> namespace cssNamespace
