module Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Elements exposing (svg, h1)
import Css.Namespace exposing (namespace)
import Styles.Shared
import Styles.Mixins


cssNamespace : String
cssNamespace =
    "elmgameroomhome"


type CssClasses
    = Root
    | Link
    | SimpleLink


css : Css.Stylesheet
css =
    stylesheet <|
        ([ class Root
            [ padding2 (px 60) (px 20)
            , textAlign center
            , display block
            , descendants
                [ svg
                    [ width (px 80)
                    , height (px 80)
                    , margin2 (px 20) auto
                    ]
                , h1
                    [ property "font-weight" "300"
                    ]
                ]
            ]
         , class Link Styles.Mixins.button
         , class SimpleLink
            [ textDecoration none
            , color (hex "2D739E")
            , borderBottom3 (px 1) solid currentColor
            , property "transition" "all 0.3s"
            , hover [ color (hex "3890c6") ]
            ]
         ]
            |> namespace cssNamespace
        )
            ++ Styles.Shared.styles


cssText : String
cssText =
    compile [ css ] |> .css


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class
