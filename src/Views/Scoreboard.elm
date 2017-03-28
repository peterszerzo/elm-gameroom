module Views.Scoreboard exposing (view)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)


view : List ( String, Int ) -> Html msg
view scores =
    div
        [ style
            [ ( "width", "100%" )
            , ( "padding", "5px" )
            , ( "background", "#eee" )
            , ( "text-align", "center" )
            ]
        ]
        [ scores
            |> List.map
                (\( player, score ) ->
                    span [ style [ ( "margin", "0 20px" ) ] ]
                        [ span [ style [ ( "margin-right", "8px" ) ] ] [ (text player) ]
                        , span [] [ (text (toString score)) ]
                        ]
                )
            |> (\list -> div [] list)
        ]
