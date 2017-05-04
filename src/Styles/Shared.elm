module Styles.Shared exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body, input, label, button, a, h1, h2, h3)
import Styles.Constants exposing (..)
import Styles.Mixins as Mixins


type CssIds
    = Root


styles : List Snippet
styles =
    [ everything
        [ boxSizing borderBox
        , property "font-family" "Source Sans Pro, Verdana, Geneva, sans-serif"
        , property "-webkit-font-smoothing" "antialiased"
        , property "-moz-osx-font-smoothing" "grayscale"
        ]
    , each [ html, body ]
        [ padding (px 0)
        , margin (px 0)
        , width (pct 100)
        , height (pct 100)
        ]
    , body
        [ position relative
        ]
    , id Root
        [ width (pct 100)
        , height (pct 100)
        ]
    , h1 Mixins.heroType
    , h2 Mixins.subheroType
    , h3 Mixins.headingType
    , input
        [ display block
        , width (pct 100)
        , padding2 (px 8) (px 8)
        , borderRadius (px 4)
        , outline none
        , boxShadow none
        , fontSize (Css.rem 1)
        , border3 (px 1) solid grey
        , marginTop (px 6)
        , property "transition" "border 0.3s"
        , focus
            [ borderColor blue
            ]
        ]
    , label
        [ display block
        , textAlign left
        , marginTop (px 30)
        , width (pct 100)
        , position relative
        , children
            [ button
                [ position absolute
                , top (px 0)
                , right (px 0)
                , border (px 0)
                , fontSize (Css.rem 1)
                , backgroundColor transparent
                ]
            ]
        ]
    ]
