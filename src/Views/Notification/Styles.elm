module Views.Notification.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "notification"


type CssClasses
    = Root
    | Body


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Snippet
styles =
    [ class Root
        [ position fixed
        , top (px 20)
        , right (px 20)
        ]
    , class Body Mixins.bodyType
    ]
        |> namespace cssNamespace
