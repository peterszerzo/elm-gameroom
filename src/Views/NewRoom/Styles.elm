module Views.NewRoom.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Elements exposing (h2, p)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "newroom"


type CssClasses
    = Root
    | Logo
    | Button
    | FormButton


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Root
        ([ children
            [ h2 Mixins.subheroType
            , p Mixins.bodyType
            ]
         ]
            ++ Mixins.centered
        )
    , class Button Mixins.button
    , class FormButton
        [ width (pct 100)
        , margin3 (px 25) (px 0) (px 0)
        ]
    ]
        |> namespace cssNamespace
