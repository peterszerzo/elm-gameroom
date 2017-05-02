module Views.Header.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)


cssNamespace : String
cssNamespace =
    "header"


type CssClasses
    = Root
    | HomeLink


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Css.Snippet
styles =
    [ class Root
        [ position fixed
        , display block
        , height (px 80)
        , width (px 80)
        , padding (px 20)
        , top (px 0)
        , left (px 0)
        ]
    , Css.class HomeLink
        [ height (px 100)
        , width (pct 100)
        , display block
        ]
    ]
        |> namespace cssNamespace