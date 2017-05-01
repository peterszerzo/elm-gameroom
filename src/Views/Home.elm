module Views.Home exposing (..)

import Html exposing (Html, div, text, h1)
import Html.CssHelpers
import Css exposing (width, height, px, margin, auto)
import Css.Namespace exposing (namespace)
import Messages exposing (Msg(..))
import Views.Link as Link
import Views.Logo as Logo
import Styles.Shared exposing (CssClasses(Centered, Hero, Link))


cssNamespace : String
cssNamespace =
    "home"


type CssClasses
    = Root
    | Logo


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


sharedClass : List class -> Html.Attribute msg
sharedClass =
    Html.CssHelpers.withNamespace "" |> .class


styles : List Css.Snippet
styles =
    [ Css.class Logo
        [ width (px 80)
        , height (px 80)
        , margin auto
        ]
    ]
        |> namespace cssNamespace


view : Html (Msg problem guess)
view =
    div [ sharedClass [ Centered ] ]
        [ div
            [ class [ Logo ]
            ]
            [ Logo.view ]
        , h1 [ sharedClass [ Hero ] ] [ text "elm-gameroom" ]
        , Link.view "/tutorial" [ sharedClass [ Link ] ] [ text "Tutorial" ]
        , Link.view "/new" [ sharedClass [ Link ] ] [ text "New room" ]
        ]
