module Views.Scoreboard exposing (..)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.CssHelpers
import Css exposing (width, pct, padding, px, backgroundColor, textAlign, center)
import Css.Namespace exposing (namespace)
import Styles.Constants exposing (lightGrey)


cssNamespace : String
cssNamespace =
    "scoreboard"


type CssClasses
    = Root


styles : List Css.Snippet
styles =
    [ Css.class Root
        [ width (pct 100)
        , padding (px 5)
        , backgroundColor lightGrey
        , textAlign center
        ]
    ]
        |> namespace cssNamespace


{ class } =
    Html.CssHelpers.withNamespace cssNamespace


view : List ( String, Int ) -> Html msg
view scores =
    div
        [ class [ Root ]
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
