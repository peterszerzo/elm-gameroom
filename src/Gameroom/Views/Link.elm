module Gameroom.Views.Link exposing (view)

import Html exposing (Html, header, text, a)
import Html.Attributes exposing (class, style, href)
import Gameroom.Messages exposing (Msg(..))


styles : List ( String, String )
styles =
    [ ( "color", "#FFF" )
    , ( "background", "#000" )
    , ( "margin", "10px" )
    , ( "padding", "6px 12px" )
    , ( "text-decoration", "none" )
    , ( "border-radius", "3px" )
    ]


view : List (Html.Attribute (Msg problemType guessType)) -> List (Html (Msg problemType guessType)) -> Html (Msg problemType guessType)
view attrs children =
    a (attrs ++ [ style styles ]) children
