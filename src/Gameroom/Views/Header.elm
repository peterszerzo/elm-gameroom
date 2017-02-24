module Gameroom.Views.Header exposing (view)

import Html exposing (Html, header, text, a)
import Html.Attributes exposing (class, style, href)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Views.Styles as Styles


styles : List ( String, String )
styles =
    [ ( "position", "fixed" )
    , ( "display", "block" )
    , ( "width", "100%" )
    , ( "height", "50px" )
    , ( "padding", "0 16px" )
    , ( "top", "0" )
    , ( "left", "0" )
    , ( "background", Styles.purple )
    , ( "box-shadow", "0 0 12px rgba(0, 0, 0, 0.2)" )
    ]


homeLinkStyles : List ( String, String )
homeLinkStyles =
    [ ( "text-decoration", "none" )
    , ( "color", "#FFF" )
    , ( "font-size", "1.25rem" )
    , ( "letter-spacing", ".05rem" )
    , ( "margin-top", "12px" )
    , ( "display", "inline-block" )
    ]


view : Html (Msg problemType guessType)
view =
    header [ style styles ] [ a [ style homeLinkStyles, href "/" ] [ text "elm-gameroom" ] ]
