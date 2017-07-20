module Page.NewRoom.Views.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "newroom"


type CssClasses
    = Root
    | Logo
    | Title
    | Button
    | ButtonDisabled
    | FormButton


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


localClassList : List ( class, Bool ) -> Html.Attribute msg
localClassList =
    Html.CssHelpers.withNamespace cssNamespace |> .classList


styles : List Snippet
styles =
    [ class Root <| Mixins.centered ++ [ textAlign left ]
    , class Button Mixins.button
    , class ButtonDisabled Mixins.buttonDisabled
    , class Title [ textAlign center ]
    , class FormButton
        [ width (pct 100)
        , margin3 (px 25) (px 0) (px 0)
        ]
    ]
        |> namespace cssNamespace
