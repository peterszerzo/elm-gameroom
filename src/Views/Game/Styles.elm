module Views.Game.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "game"


type CssClasses
    = Root
    | GamePlay
    | GamePlayInCooldown
    | ReadyPrompt
    | Link
    | DisabledLink


localClass : List class -> Html.Attribute msg
localClass =
    Html.CssHelpers.withNamespace cssNamespace |> .class


localClassList : List ( class, Bool ) -> Html.Attribute msg
localClassList =
    Html.CssHelpers.withNamespace cssNamespace |> .classList


styles : List Css.Snippet
styles =
    [ class Root []
    , class GamePlay
        [ position absolute
        , top (px 0)
        , bottom (px 0)
        , left (px 0)
        , right (px 0)
        , property "transition" "opacity 2s"
        ]
    , class GamePlayInCooldown
        [ opacity (num 0.3)
        ]
    , class ReadyPrompt Mixins.centered
    , class Link Mixins.button
    , class DisabledLink Mixins.buttonDisabled
    ]
        |> namespace cssNamespace
