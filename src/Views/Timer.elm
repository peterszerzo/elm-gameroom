module Views.Timer exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)


view : Float -> Html msg
view ratio =
    div
        [ style
            [ ( "position", "absolute" )
            , ( "top", "-2px" )
            , ( "height", "2px" )
            , ( "left", "0" )
            , ( "background", "#ddd" )
            , ( "width", ((max (1 - ratio) 0) * 100 |> toString) ++ "%" )
            ]
        ]
        [ text " " ]
