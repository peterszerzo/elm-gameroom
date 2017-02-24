module Gameroom.Views.Styles exposing (..)


blue : String
blue =
    "rgb(67, 94, 137)"


purple : String
purple =
    "rgb(77, 80, 97)"


offWhite : String
offWhite =
    "rgb(244, 244, 248)"


black : String
black =
    "rgb(24, 20, 10)"


red : String
red =
    "rgb(254, 74, 73)"


font : String
font =
    "Arial, Helvetica, sans-serif"


centered : List ( String, String )
centered =
    [ ( "max-width", "600px" )
    , ( "max-height", "600px" )
    , ( "position", "absolute" )
    , ( "top", "50%" )
    , ( "left", "50%" )
    , ( "transform", "translate3d(-50%, -50%, 0) scale(1.0, 1.0)" )
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
    , ( "padding", "6px 12px" )
    , ( "border-radius", "4px" )
    , ( "outline", "0" )
    , ( "border", "1px solid #ddd" )
    , ( "margin-top", "6px" )
    , ( "font-size", "1rem" )
    ]


heroType : List ( String, String )
heroType =
    [ ( "font-size", "4rem" )
    , ( "font-weight", "300" )
    , ( "margin", "20px auto 40px" )
    , ( "font-family", font )
    ]


link : List ( String, String )
link =
    [ ( "color", "#FFF" )
    , ( "display", "inline-block" )
    , ( "background", blue )
    , ( "font-family", font )
    , ( "font-size", "1rem" )
    , ( "letter-spacing", ".05rem" )
    , ( "margin", "10px" )
    , ( "padding", "8px 16px" )
    , ( "text-decoration", "none" )
    , ( "border-radius", "3px" )
    , ( "border", "none" )
    ]
