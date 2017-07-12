module Views.Scoreboard exposing (view)

import Html exposing (Html, div, text, span)
import Views.Scoreboard.Styles exposing (CssClasses(..), localClass)


view : List ( String, Int ) -> Html msg
view scores =
    div
        [ localClass [ Root ]
        ]
        [ scores
            |> List.map
                (\( player, score ) ->
                    span [ localClass [ List ] ]
                        [ span [ localClass [ Player ] ] [ (text player) ]
                        , span [ localClass [ Score ] ] [ (text (toString score)) ]
                        ]
                )
            |> (\list -> div [] list)
        ]
