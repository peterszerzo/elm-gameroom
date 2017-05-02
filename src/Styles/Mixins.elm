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



--  Typography


bodyType : List Mixin
bodyType =
    [ fontSize (Css.rem 1)
    , property "font-weight" "300"
    , margin2 (px 10) auto
    ]


heroType : List Mixin
heroType =
    [ fontSize (Css.rem 3)
    , property "font-weight" "300"
    , margin2 (px 20) auto
    ]


subheroType : List Mixin
subheroType =
    [ fontSize (Css.rem 3)
    , property "font-weight" "300"
    , margin3 (px 20) auto (px 40)
    ]



-- Buttons


button : List Mixin
button =
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
    , outline none
    , boxShadow none
    ]


buttonDisabled : List Mixin
buttonDisabled =
    [ border3 (px 2) solid blue
    , color blue
    , backgroundColor transparent
    , property "opacity" "0.8"
    ]
