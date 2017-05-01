module Views.Home.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)


cssNamespace : String
cssNamespace =
    "home"


type CssClasses
    = Root
    | Logo


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Logo
        [ width (px 80)
        , height (px 80)
        , margin auto
        ]
    ]
        |> namespace cssNamespace
