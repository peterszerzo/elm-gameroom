module Views.Attribution.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Elements exposing (svg, p, a, span)
import Css.Namespace exposing (namespace)
import Styles.Constants exposing (..)


cssNamespace : String
cssNamespace =
    "attribution"


type CssClasses
    = Root


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Css.Snippet
styles =
    [ Css.class Root
        [ position fixed
        , bottom (px 10)
        , opacity (num 0.4)
        , color (hex black)
        , textDecoration none
        , fontSize (Css.rem 0.75)
        , property "transition" "all 0.3s"
        , hover
            [ opacity (num 1.0)
            ]
        , descendants
            [ svg
                [ width (px 24)
                , height (px 24)
                , display inlineBlock
                , verticalAlign middle
                , position relative
                , top (px -5)
                ]
            , everything
                [ display inlineBlock
                , verticalAlign middle
                ]
            , span
                [ firstOfType
                    [ width (px 100)
                    , textAlign right
                    , marginRight (px 6)
                    ]
                , lastOfType
                    [ width (px 100)
                    , textAlign left
                    , marginLeft (px 6)
                    ]
                ]
            ]
        ]
    ]
        |> namespace cssNamespace
