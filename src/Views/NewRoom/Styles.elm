module Views.NewRoom.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins
import Styles.Constants exposing (..)


cssNamespace : String
cssNamespace =
    "newroom"


type CssClasses
    = Root
    | Logo
    | Button
    | FormButton
    | Notification
    | NotificationHidden


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


localClassList : List ( class, Bool ) -> Html.Attribute msg
localClassList =
    Html.CssHelpers.withNamespace cssNamespace |> .classList


styles : List Snippet
styles =
    [ class Root Mixins.centered
    , class Button Mixins.button
    , class FormButton
        [ width (pct 100)
        , margin3 (px 25) (px 0) (px 0)
        ]
    , class Notification <|
        [ position fixed
        , top (px 20)
        , right (px 20)
        , maxWidth (px 280)
        , backgroundColor (hex blue)
        , color (hex white)
        , borderRadius (px standardBorderRadius)
        , padding2 (px 8) (px 16)
        , textAlign left
        , descendants
            [ everything
                [ margin (px 0)
                ]
            ]
        ]
            ++ Mixins.standardBoxShadow
    , class NotificationHidden [ display none ]
    ]
        |> namespace cssNamespace
