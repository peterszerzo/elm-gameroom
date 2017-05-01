module Views.Header exposing (..)

import Html exposing (Html, header, text)
import Html.CssHelpers
import Css exposing (position, fixed, display, block, px, pct, height, width, padding, top, left)
import Css.Namespace exposing (namespace)
import Messages exposing (Msg(..))
import Views.Logo as Logo
import Views.Link as Link


cssNamespace : String
cssNamespace =
    "header"


type CssClasses
    = Root
    | HomeLink


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


styles : List Css.Snippet
styles =
    [ Css.class Root
        [ position fixed
        , display block
        , height (px 80)
        , width (px 80)
        , padding (px 20)
        , top (px 0)
        , left (px 0)
        ]
    , Css.class HomeLink
        [ height (px 100)
        , width (pct 100)
        , display block
        ]
    ]
        |> namespace cssNamespace


view : Html (Msg problem guess)
view =
    header [ class [ Root ] ]
        [ Link.view "/" [ class [ HomeLink ] ] [ Logo.view ]
        ]
