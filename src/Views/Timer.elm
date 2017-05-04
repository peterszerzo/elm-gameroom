module Views.Timer exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Views.Timer.Styles exposing (CssClasses(..), localClass)


view : Float -> Html msg
view ratio =
    let
        widthPercentage =
            ((max (ratio) 0) * 100 |> toString) ++ "%"
    in
        div
            [ localClass [ Root ]
            , style
                [ ( "transform", "translateX(-" ++ widthPercentage ++ ")" )
                ]
            ]
            [ text " " ]
