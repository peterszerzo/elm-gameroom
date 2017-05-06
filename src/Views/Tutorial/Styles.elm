module Views.Tutorial.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Constants exposing (..)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "tutorial"


type CssClasses
    = Root
    | Button


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Root [ width (pct 100), height (pct 100), position fixed ]
    , class Button <|
        [ width (px 40)
        , height (px 40)
        , backgroundColor (hex blue)
        , color (hex white)
        , position fixed
        , top (pct 50)
        , right (px 20)
        , textAlign center
        , fontSize (px 20)
        , paddingTop (px 8)
        , borderRadius (pct 50)
        , transform (translate3d (px 0) (pct -50) (px 0))
        , after
            [ property "content" "' '"
            , position absolute
            , top (px 0)
            , left (px 0)
            , bottom (px 0)
            , right (px 0)
            , property "transition" "background-color 0.3s"
            ]
        , hover
            [ after
                [ property "background-color" "rgba(255, 255, 255, 0.1)"
                ]
            ]
        ]
            ++ Mixins.standardBoxShadow
    ]
        |> namespace cssNamespace
