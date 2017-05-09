port module Main exposing (..)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (program, Model, Msg, Ports)
import Gameroom.Spec exposing (Spec)
import Gameroom.Utilities exposing (generatorFromList)


-- Types


type alias Problem =
    String


type alias Guess =
    Int



-- Spec


spec : Spec Problem Guess
spec =
    { copy =
        { name = "Lettero"
        , subheading = "A mildly frustrating wordgame!"
        , instructions = "Hit the first letter of the word!"
        }
    , view =
        (\windowSize ticksSinceNewRound playerId players problem ->
            div
                [ style
                    [ ( "position", "absolute" )
                    , ( "width", "75vmin" )
                    , ( "height", "75vmin" )
                    , ( "top", "50%" )
                    , ( "left", "50%" )
                    , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0) rotate(" ++ ((ticksSinceNewRound |> toFloat) / 5 |> toString) ++ "deg)" )
                    ]
                ]
                (problem
                    |> String.toList
                    |> List.indexedMap
                        (\index c ->
                            let
                                angle =
                                    (index |> toFloat)
                                        / (problem
                                            |> String.length
                                            |> toFloat
                                          )
                                        |> (*) (2 * pi)
                            in
                                span
                                    [ style
                                        [ ( "position", "absolute" )
                                        , ( "display", "block" )
                                        , ( "cursor", "pointer" )
                                        , ( "background-color", "rgba(255, 255, 255, 0.1)" )
                                        , ( "font-size", "calc(3vh + 3vw)" )
                                        , ( "padding", "20px" )
                                        , ( "top", ((1 - sin angle) * 50 |> toString) ++ "%" )
                                        , ( "left", ((1 - cos angle) * 50 |> toString) ++ "%" )
                                        , ( "transform", "translate3d(-50%, -50%, 0) rotate(" ++ ((angle * 180 / pi - 90) |> toString) ++ "deg)" )
                                        , ( "text-transform", "uppercase" )
                                        ]
                                    , onClick index
                                    ]
                                    [ text (String.fromChar c) ]
                        )
                )
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , problemGenerator =
        generatorFromList "perrywinkle"
            [ "gingerberry"
            , "apples"
            , "vineyard"
            , "is"
            , "tablespoon"
            , "cutlery"
            , "laborer"
            , "projector"
            ]
    , guessEncoder = JE.int
    , guessDecoder = JD.int
    , problemEncoder = JE.string
    , problemDecoder = JD.string
    }



-- Config


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    Gameroom.programAt "lettero" spec ports
