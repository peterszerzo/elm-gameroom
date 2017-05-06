module Views.Scoreboard.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Constants exposing (..)


cssNamespace : String
cssNamespace =
    "scoreboard"


type CssClasses
    = Root
    | List
    | Player
    | Score


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Root
        [ width (pct 100)
        , padding (px 5)
        , backgroundColor (hex lightBlue)
        , color (hex white)
        , textAlign center
        ]
    , class List [ margin2 (px 0) (px 20) ]
    , class Player [ marginRight (px 8) ]
    ]
        |> namespace cssNamespace
