module Styles exposing (..)

import Css exposing (..)
import Css.Elements exposing (h1, html, body, input, label)
import Css.Namespace exposing (namespace)


type CssClasses
    = App
    | Link
    | LinkDisabled
    | Hero
    | Subhero
    | Body
    | Centered


type CssIds
    = Root


grey : Color
grey =
    hex "DDDDDD"


white : Color
white =
    hex "FFFFFF"


blue : Color
blue =
    rgb 67 94 137


purple : Color
purple =
    rgb 77 80 97


css : Stylesheet
css =
    (stylesheet << namespace "")
        [ everything
            [ boxSizing borderBox
            , property "font-family" "monospace"
            , property "-webkit-font-smoothing" "antialiased"
            , property "-moz-osx-font-smoothing" "grayscale"
            ]
        , each [ html, body ]
            [ padding (px 0)
            , margin (px 0)
            , width (pct 100)
            , height (pct 100)
            ]
        , id Root
            [ width (pct 100)
            , height (pct 100)
            ]
        , class App
            [ position fixed
            , top (px 0)
            , bottom (px 0)
            , left (px 0)
            , right (px 0)
            , backgroundColor white
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
        , body
            [ position relative
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
        , class Hero
            [ fontSize (Css.rem 4)
            , property "font-weight" "300"
            , margin3 (px 20) auto (px 40)
            ]
        , class Subhero
            [ fontSize (Css.rem 3)
            , property "font-weight" "300"
            , margin3 (px 20) auto (px 40)
            ]
        , class Body
            [ fontSize (Css.rem 1)
            , property "font-weight" "300"
            , margin2 (px 10) auto
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
        ]
