module Views.Game.Styles exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Elements exposing (h2)
import Css.Namespace exposing (namespace)
import Styles.Mixins as Mixins


cssNamespace : String
cssNamespace =
    "game"


type CssClasses
    = Root
    | GamePlay
    | ReadyPrompt
    | Title
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
        [ width (pct 100)
        , height (pct 100)
        ]
    , class ReadyPrompt
        ([ children
            [ h2 Mixins.subheroType
            ]
         ]
            ++ Mixins.centered
        )
    , class Title Mixins.subheroType
    , class Link Mixins.button
    , class DisabledLink Mixins.buttonDisabled
    ]
        |> namespace cssNamespace
