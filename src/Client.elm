module Client exposing (..)

import Random
import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (Spec)


type alias ProblemType =
    String


type alias GuessType =
    Int


centeredStyle : List ( String, String )
centeredStyle =
    [ ( "position", "absolute" )
    , ( "max-width", "800px" )
    , ( "max-height", "800px" )
    , ( "top", "50%" )
    , ( "left", "50%" )
    , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0)" )
    ]


words : List String
words =
    [ "perrywinkle"
    , "gingerberry"
    , "apples"
    , "vineyard"
    ]


gameSpec : Spec ProblemType GuessType
gameSpec =
    { view =
        (\playerId players problem ->
            div [ style centeredStyle ]
                [ div [ class "word " ]
                    (problem
                        |> String.toList
                        |> List.indexedMap (\index c -> span [ style [ ( "font-size", "2rem" ) ], onClick index ] [ text (String.fromChar c) ])
                    )
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , guessEncoder = JE.int
    , guessDecoder = JD.int
    , problemGenerator =
        Random.int 0 (List.length words - 1)
            |> Random.map
                (\i ->
                    words
                        |> List.drop i
                        |> List.head
                        |> Maybe.withDefault "perrywinkle"
                )
    , problemEncoder = JE.string
    , problemDecoder = JD.string
    }
