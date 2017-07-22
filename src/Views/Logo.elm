module Views.Logo exposing (view, animatedView)

import Html exposing (Html)
import Time
import Svg exposing (svg, polygon)
import Svg.Attributes exposing (points, viewBox, width, height, stroke, strokeWidth, fill, transform)
import Styles.Constants exposing (..)


type alias Polygon =
    { coords : List ( Float, Float )
    , color : String
    , transform : ( Float, Float )
    , transformPhase : Float
    }


polygons : List Polygon
polygons =
    [ { coords =
            [ ( 30.0, -30.0 )
            , ( 30.0, 3.33 )
            , ( 13.33, -13.33 )
            ]
      , color = cyan
      , transform = ( 0, 2 )
      , transformPhase = pi / 2
      }
    , { coords =
            [ ( 30.0, -30.0 )
            , ( 13.33, -13.33 )
            , ( -3.33, -30.0 )
            ]
      , color = blue
      , transform = ( 0, 0 )
      , transformPhase = 0
      }
    , { coords =
            [ ( 16.67, 1.71 )
            , ( 16.67, 15.05 )
            , ( 30.0, 15.05 )
            ]
      , color = black
      , transform = ( 0, 0 )
      , transformPhase = 0
      }
    , { coords =
            [ ( 3.33, -17.55 )
            , ( 16.67, -4.22 )
            , ( 3.33, 9.12 )
            ]
      , color = red
      , transform = ( 0, 4 )
      , transformPhase = pi / 2
      }
    , { coords =
            [ ( -3.33, 6.0 )
            , ( -16.67, -7.33 )
            , ( -30.0, 6.0 )
            ]
      , color = blue
      , transform = ( 0, 0 )
      , transformPhase = 0
      }
    , { coords =
            [ ( -16.67, -14.16 )
            , ( -3.33, -27.49 )
            , ( -3.33, -1.17 )
            ]
      , color = cyan
      , transform = ( 0, 0 )
      , transformPhase = 0
      }
    , { coords =
            [ ( -30.0, -3.33 )
            , ( -30.0, -30.0 )
            , ( -3.33, -30.0 )
            ]
      , color = black
      , transform = ( 0, 0 )
      , transformPhase = 0
      }
    ]


viewPolygon : Float -> Time.Time -> Polygon -> Html msg
viewPolygon amplitude time { coords, color, transform, transformPhase } =
    let
        sinTime =
            sin (time / 1000 + transformPhase)

        factor =
            amplitude * sinTime

        dx =
            factor * (Tuple.first transform)

        dy =
            factor * (Tuple.second transform)
    in
        polygon
            [ points
                (coords
                    |> List.map
                        (\( x, y ) ->
                            (toString (x + dx)) ++ "," ++ (toString (-(y + dy)))
                        )
                    |> String.join " "
                )
            , stroke "#FFF"
            , strokeWidth "1.5"
            , fill ("#" ++ color)
            ]
            []


view : Html msg
view =
    animatedView 0 0


animatedView : Float -> Time.Time -> Html msg
animatedView amplitude time =
    svg [ viewBox "-30 -30 60 60" ]
        (List.map (viewPolygon amplitude time) polygons)
