module Styles.Mixins exposing (..)

import Css exposing (..)
import Styles.Constants exposing (..)


-- Utilities


centered : List Mixin
centered =
    [ maxWidth (px 400)
    , maxHeight (pct 100)
    , overflowY auto
    , width (pct 100)
    , position absolute
    , top (pct 50)
    , left (pct 50)
    , transform (translate2 (pct -50) (pct -50))
    , textAlign center
    ]


standardBoxShadow : List Mixin
standardBoxShadow =
    [ property "box-shadow" "0 0 18px rgba(0, 0, 0, 0.08), 0 0 6px rgba(0, 0, 0, 0.16)"
    ]



--  Typography


heroType : List Mixin
heroType =
    [ fontSize (Css.rem 3.25)
    , property "font-weight" "300"
    , letterSpacing (Css.rem 0.05)
    , margin2 (px 20) auto
    ]


subheroType : List Mixin
subheroType =
    [ fontSize (Css.rem 2.25)
    , property "font-weight" "300"
    , letterSpacing (Css.rem 0.05)
    , margin3 (px 20) auto (px 40)
    ]


headingType : List Mixin
headingType =
    [ fontSize (Css.rem 1.5)
    , property "font-weight" "300"
    , letterSpacing (Css.rem 0.05)
    , margin3 (px 20) auto (px 40)
    ]


bodyType : List Mixin
bodyType =
    [ fontSize (Css.rem 1)
    , property "font-weight" "400"
    , letterSpacing (Css.rem 0.05)
    , margin2 (px 10) auto
    ]



-- Buttons


button : List Mixin
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
    , borderRadius (px 3)
    , border (px 0)
    , outline none
    , boxShadow none
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


buttonDisabled : List Mixin
buttonDisabled =
    [ border3 (px 2) solid (hex blue)
    , color (hex blue)
    , backgroundColor transparent
    , property "opacity" "0.8"
    ]
