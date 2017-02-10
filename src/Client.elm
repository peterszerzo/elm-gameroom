module Client exposing (..)

import Random
import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Models.Spec exposing (Spec)


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
    , ( "transform", "scale(1) translate3d(-50%, -50%, 0)" )
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
        (\playerId room ->
            div [ style centeredStyle ]
                [ text ("round no. " ++ (toString room.round.no))
                , div [ class "word " ]
                    (room.round.problem
                        |> Maybe.withDefault "loading"
                        |> String.toList
                        |> List.indexedMap (\index c -> span [ onClick index ] [ text (String.fromChar c) ])
                    )
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , guessEncoder = (JE.int)
    , guessDecoder = (JD.int)
    , problemGenerator =
        Random.int 0 (List.length words - 1)
            |> Random.map
                (\i ->
                    words |> List.drop i |> List.head |> Maybe.withDefault "perrywinkle"
                )
    , problemEncoder =
        (\problem ->
            problem |> Maybe.map JE.string |> Maybe.withDefault (JE.string "null")
        )
    , problemDecoder =
        (JD.string
            |> JD.andThen
                (\s ->
                    if s == "null" then
                        JD.succeed Nothing
                    else
                        JD.succeed (Just s)
                )
        )
    }
