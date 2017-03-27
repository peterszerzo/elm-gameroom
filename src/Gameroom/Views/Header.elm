module Gameroom.Views.Header exposing (view)

import Html exposing (Html, header, text, a)
import Html.Attributes exposing (class, style, href)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Views.Logo as Logo
import Gameroom.Views.Link as Link


styles : List ( String, String )
styles =
    [ ( "position", "fixed" )
    , ( "display", "block" )
    , ( "height", "80px" )
    , ( "width", "80px" )
    , ( "padding", "20px" )
    , ( "top", "0" )
    , ( "left", "0" )
    ]


homeLinkStyles : List ( String, String )
homeLinkStyles =
    [ ( "height", "100%" )
    , ( "width", "100%" )
    , ( "display", "block" )
    ]


view : Html (Msg problemType guessType)
view =
    header [ style styles ]
        [ Link.view "/" [ style homeLinkStyles ] [ Logo.view ]
        ]
