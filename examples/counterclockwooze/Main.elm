port module Main exposing (..)

import Random
import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style, attribute)
import Html.Events exposing (onClick)
import Svg exposing (polygon, svg, g)
import Svg.Attributes exposing (width, height, viewBox, points, transform)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (program, Model, Msg, Ports)
import Gameroom.Spec exposing (Spec)


-- Types


type alias Point =
    { x : Float
    , y : Float
    }


type alias Problem =
    List Point


type alias Guess =
    Int



-- Spec


spec : Spec Problem Guess
spec =
    { copy =
        { name = "Counterclockwooze"
        , subheading = "A great game to play with your friends"
        , instructions = "Find the one shape that spins the other way."
        }
    , view =
        (\windowSize ticksSinceNewRound _ problem ->
            div
                [ class "spinning-shapes-container"
                , style
                    [ ( "position", "absolute" )
                    , ( "width", "80vmin" )
                    , ( "height", "80vmin" )
                    , ( "top", "50%" )
                    , ( "left", "50%" )
                    , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0)" )
                    ]
                ]
                [ svg [ viewBox "0 0 1000 1000" ]
                    (List.indexedMap
                        (\index { x, y } ->
                            let
                                translateString =
                                    ("translate(" ++ (toString (x * 900 + 50)) ++ "," ++ (toString (y * 900 + 50)) ++ ")")
                            in
                                g [ transform translateString ]
                                    [ polygon
                                        [ points "-50,-28.8 50,-28.8 0,57.7"
                                        , attribute "transform"
                                            ("rotate("
                                                ++ ((ticksSinceNewRound |> toFloat)
                                                        |> (*) 0.5
                                                        |> (*)
                                                            (if index == 0 then
                                                                1
                                                             else
                                                                -1
                                                            )
                                                        |> toString
                                                   )
                                                ++ ")"
                                            )
                                        , onClick index
                                        ]
                                        []
                                    ]
                        )
                        problem
                    )
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , problemGenerator =
        Random.list 10 (Random.map2 Point (Random.float 0 1) (Random.float 0 1))
    , guessEncoder = JE.int
    , guessDecoder = JD.int
    , problemEncoder =
        List.map
            (\triangle ->
                JE.object
                    [ ( "x", JE.float triangle.x )
                    , ( "y", JE.float triangle.y )
                    ]
            )
            >> JE.list
    , problemDecoder =
        JD.list
            (JD.map2 Point
                (JD.field "x" JD.float)
                (JD.field "y" JD.float)
            )
    }



-- Config


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }



-- Program


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    Gameroom.programAt "counterclockwooze" spec ports
