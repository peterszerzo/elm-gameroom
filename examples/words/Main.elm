module Main exposing (..)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (program, Model, Msg, Spec, generatorFromList)


type alias ProblemType =
    String


type alias GuessType =
    Int


gameSpec : Spec ProblemType GuessType
gameSpec =
    { view =
        (\playerId players problem ->
            div
                [ style
                    [ ( "position", "absolute" )
                    , ( "max-width", "800px" )
                    , ( "max-height", "800px" )
                    , ( "top", "50%" )
                    , ( "left", "50%" )
                    , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0)" )
                    ]
                ]
                [ div [ class "word " ]
                    (problem
                        |> String.toList
                        |> List.indexedMap
                            (\index c ->
                                span
                                    [ style
                                        [ ( "font-size", "2rem" )
                                        ]
                                    , onClick index
                                    ]
                                    [ text (String.fromChar c) ]
                            )
                    )
                ]
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


main : Program Never (Model ProblemType GuessType) (Msg ProblemType GuessType)
main =
    Gameroom.program gameSpec
