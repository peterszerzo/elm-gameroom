module Styles.Shared exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body, input, label)
import Styles.Constants exposing (..)


type CssIds
    = Root


type CssClasses
    = Hero
    | Subhero
    | Centered
    | Link
    | LinkDisabled
    | Body


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
    , class Hero
        [ fontSize (Css.rem 3)
        , property "font-weight" "300"
        , margin3 (px 20) auto (px 40)
        ]
    , class Subhero
        [ fontSize (Css.rem 3)
        , property "font-weight" "300"
        , margin3 (px 20) auto (px 40)
        ]
    , class Centered
        [ maxWidth (px 600)
        , maxHeight (px 600)
        , position absolute
        , top (pct 50)
        , left (pct 50)
        , transform (translate2 (pct -50) (pct -50))
        , textAlign center
        ]
    , class Link
        [ color white
        , cursor pointer
        , display inlineBlock
        , backgroundColor blue
        , fontSize (Css.rem 1)
        , letterSpacing (Css.rem 0.05)
        , margin (px 10)
        , padding2 (px 8) (px 16)
        , textDecoration none
        , borderRadius (px 3)
        , border (px 0)
        ]
    , class LinkDisabled
        [ border3 (px 2) solid blue
        , color blue
        , backgroundColor transparent
        , property "opacity" "0.8"
        ]
    , class Body
        [ fontSize (Css.rem 1)
        , property "font-weight" "300"
        , margin2 (px 10) auto
        ]
    , input
        [ display block
        , width (pct 100)
        , padding2 (px 6) (px 12)
        , borderRadius (px 4)
        , outline none
        , boxShadow none
        , fontSize (Css.rem 1)
        , border3 (px 1) solid grey
        , marginTop (px 6)
        ]
    , label
        [ display block
        , textAlign left
        , marginTop (px 20)
        , width (pct 100)
        ]
    ]
