module Styles.Mixins exposing (..)

import Css exposing (..)
import Styles.Constants exposing (..)


-- Utilities


centered : List Style
centered =
    [ maxWidth (px 540)
    , maxHeight (pct 100)
    , overflowY auto
    , width (pct 100)
    , margin (px 0)
    , padding (px 20)
    , textAlign center
    ]


standardBoxShadow : List Style
standardBoxShadow =
    [ property "box-shadow" "0 0 18px rgba(0, 0, 0, 0.08), 0 0 6px rgba(0, 0, 0, 0.16)"
    ]



--  Typography


heroType : List Style
heroType =
    [ fontSize (Css.rem 2.5)
    , property "font-weight" "300"
    , letterSpacing (Css.rem 0.05)
    , margin2 (px 10) auto
    ]


subheroType : List Style
subheroType =
    [ fontSize (Css.rem 2)
    , property "font-weight" "300"
    , letterSpacing (Css.rem 0.05)
    , margin3 (px 20) auto (px 20)
    ]


headingType : List Style
headingType =
    [ fontSize (Css.rem 1.5)
    , property "font-weight" "300"
    , letterSpacing (Css.rem 0.05)
    , margin3 (px 20) auto (px 40)
    ]


bodyType : List Style
bodyType =
    [ fontSize (Css.rem 1)
    , property "font-weight" "400"
    , letterSpacing (Css.rem 0.05)
    , lineHeight (num 1.5)
    , margin2 (px 10) auto
    ]



-- Buttons


button : List Style
button =
    [ color (hex white)
    , cursor pointer
    , position relative
    , display inlineBlock
    , backgroundColor (hex blue)
    , fontSize (Css.rem 1)
    , letterSpacing (Css.rem 0.05)
    , margin (px 10)
    , padding2 (px 8) (px 16)
    , textDecoration none
    , borderRadius (px standardBorderRadius)
    , border (px 0)
    , outline none
    , border3 (px 1) solid (hex blue)
    , property "transition" "all 0.3s"
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
    , focus
        [ outline3 (px 2) solid (hex blue)
        , outlineOffset (px 2)
        ]
    ]
        ++ standardBoxShadow


buttonDisabled : List Style
buttonDisabled =
    [ borderColor (hex darkGrey)
    , color (hex darkGrey)
    , backgroundColor transparent
    , property "opacity" "0.6"
    , cursor initial
    , boxShadow none
    ]
