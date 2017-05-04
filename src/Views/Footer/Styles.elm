module Views.Footer.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "footer"


type CssClasses
    = Root


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Css.Snippet
styles =
    [ Css.class Root <|
        [ position fixed
        , right (px 0)
        , bottom (px 0)
        , width (pct 100)
        ]
            ++ Mixins.standardBoxShadow
    ]
        |> namespace cssNamespace
