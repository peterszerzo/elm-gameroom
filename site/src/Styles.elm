module Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Elements exposing (svg, h1, main_, footer, header)
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
                    [ width (px 60)
                    , height (px 60)
                    , margin auto
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
         , header
            [ paddingBottom (px 30)
            ]
         , main_
            [ padding2 (px 60) (px 20)
            , maxWidth (px 640)
            , margin auto
            , borderTop3 (px 1) solid (hex "cccccc")
            , borderBottom3 (px 1) solid (hex "cccccc")
            ]
         , footer
            [ maxWidth (px 640)
            , padding2 (px 30) (px 40)
            , margin auto
            , descendants
                [ everything
                    [ maxWidth (px 400)
                    ]
                ]
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
