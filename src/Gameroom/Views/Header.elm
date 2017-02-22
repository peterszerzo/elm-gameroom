module Gameroom.Views.Header exposing (view)

import Html exposing (Html, header, text, a)
import Html.Attributes exposing (class, style, href)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Views.Link as Link


styles : List ( String, String )
styles =
    [ ( "position", "fixed" )
    , ( "display", "block" )
    , ( "width", "100%" )
    , ( "padding", "16px 16px" )
    , ( "top", "0" )
    , ( "left", "0" )
    , ( "background", "#FFF" )
    , ( "box-shadow", "0 0 8px rgba(0, 0, 0, 0.1)" )
    ]


view : Html (Msg problemType guessType)
view =
    header [ style styles ] [ Link.view [ href "/" ] [ text "elm-gameroom" ] ]
