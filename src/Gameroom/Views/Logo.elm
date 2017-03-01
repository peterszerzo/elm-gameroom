module Gameroom.Views.Logo exposing (view)

import Html exposing (Html)
import Svg exposing (svg, polygon)
import Svg.Attributes exposing (points, viewBox, width, height, stroke, strokeWidth, fill)
import Gameroom.Views.Styles as Styles


polygons : List (List (List Float))
polygons =
    [ [ [ 30.0, -30.0 ]
      , [ 30.0, 3.33 ]
      , [ 13.33, -13.33 ]
      ]
    , [ [ 30.0, -30.0 ]
      , [ 13.33, -13.33 ]
      , [ -3.33, -30.0 ]
      ]
    , [ [ 16.67, 1.71 ]
      , [ 16.67, 15.05 ]
      , [ 30.0, 15.05 ]
      ]
    , [ [ 3.33, -17.55 ]
      , [ 16.67, -4.22 ]
      , [ 3.33, 9.12 ]
      ]
    , [ [ -3.33, 6.0 ]
      , [ -16.67, -7.33 ]
      , [ -30.0, 6.0 ]
      ]
    , [ [ -16.67, -12.16 ]
      , [ -3.33, -25.49 ]
      , [ -3.33, 1.17 ]
      ]
    , [ [ -30.0, -3.33 ]
      , [ -30.0, -30.0 ]
      , [ -3.33, -30.0 ]
      ]
    ]


viewPolygon : Int -> List (List Float) -> Html msg
viewPolygon index pointCoordinates =
    polygon
        [ points
            (List.map
                (\pt ->
                    List.indexedMap
                        (\i coord ->
                            if i == 0 then
                                toString coord
                            else
                                toString (-coord)
                        )
                        pt
                        |> String.join ","
                )
                pointCoordinates
                |> String.join " "
            )
        , stroke "#FFF"
        , strokeWidth "1.5"
        , fill
            (case index of
                0 ->
                    Styles.elmCyan

                1 ->
                    Styles.elmGreen

                2 ->
                    Styles.elmOrange

                3 ->
                    Styles.elmDark

                4 ->
                    Styles.elmOrange

                5 ->
                    Styles.elmCyan

                6 ->
                    Styles.elmDark

                _ ->
                    Styles.black
            )
        ]
        []


view : Html msg
view =
    svg [ viewBox "-30 -30 60 60" ] (List.indexedMap viewPolygon polygons)
