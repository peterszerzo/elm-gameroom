module Main exposing (..)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Models.Spec exposing (Spec)
import Models.Main exposing (Model)
import Json.Encode as JE
import Json.Decode as JD
import Program
import Messages exposing (Msg)


gameSpec : Spec String Int
gameSpec =
    { view =
        (\playerId room ->
            div []
                [ text ("round no. " ++ (toString room.round.no))
                , div [ class "word " ]
                    (room.round.problem
                        |> String.toList
                        |> List.indexedMap (\index c -> span [ onClick index ] [ text (String.fromChar c) ])
                    )
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , guessEncoder = (JE.int)
    , guessDecoder = (JD.int)
    , problemEncoder = (JE.string)
    , problemDecoder = (JD.string)
    }


main : Program Never (Model String Int) (Msg String Int)
main =
    Program.program gameSpec
