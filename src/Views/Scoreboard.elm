module Views.Scoreboard exposing (view)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.CssHelpers
import Styles


{ class } =
    Html.CssHelpers.withNamespace ""


view : List ( String, Int ) -> Html msg
view scores =
    div
        [ class [ Styles.ScoreBoard ]
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
