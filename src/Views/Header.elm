module Views.Header exposing (view)

import Html exposing (Html, header, text)
import Html.Attributes exposing (class, style, href)
import Messages exposing (Msg(..))
import Views.Logo as Logo
import Views.Link as Link


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


view : Html (Msg problem guess)
view =
    header [ style styles ]
        [ Link.view "/" [ style homeLinkStyles ] [ Logo.view ]
        ]
