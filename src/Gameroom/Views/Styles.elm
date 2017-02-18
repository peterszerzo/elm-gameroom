module Gameroom.Views.Styles exposing (..)


centered : List ( String, String )
centered =
    [ ( "max-width", "600px" )
    , ( "max-height", "600px" )
    , ( "position", "absolute" )
    , ( "top", "50%" )
    , ( "left", "50%" )
    , ( "transform", "translate3d(-50%, -50%, 0)" )
    , ( "text-align", "center" )
    ]


label : List ( String, String )
label =
    [ ( "display", "block" )
    , ( "text-align", "left" )
    , ( "margin-top", "20px" )
    , ( "width", "100%" )
    ]


input : List ( String, String )
input =
    [ ( "display", "block" )
    , ( "width", "100%" )
    , ( "padding", "5px 10px" )
    , ( "outline", "0" )
    ]
