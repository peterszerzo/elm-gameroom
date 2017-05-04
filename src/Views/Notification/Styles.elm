module Views.Notification.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Constants exposing (..)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "notification"


type CssClasses
    = Root
    | RootActive


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


localClassList : List ( class, Bool ) -> Html.Attribute msg
localClassList =
    Html.CssHelpers.withNamespace cssNamespace |> .classList


styles : List Snippet
styles =
    [ class Root <|
        [ position fixed
        , top (px 20)
        , right (px 20)
        , opacity (num 0)
        , property "pointer-events" "none"
        , backgroundColor (hex blue)
        , color (hex white)
        , borderRadius (px standardBorderRadius)
        , padding2 (px 10) (px 20)
        , descendants
            [ everything [ margin (px 0) ]
            ]
        ]
            ++ Mixins.standardBoxShadow
    , class RootActive
        [ opacity (num 1)
        , property "pointer-events" "all"
        , property "transition" "opacity 0.3s"
        ]
    ]
        |> namespace cssNamespace
