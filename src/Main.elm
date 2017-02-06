module Main exposing (..)

import Html exposing (Html, beginnerProgram, div, button, text)
import Html.Events exposing (onClick)
import GameRoom
import Json.Encode as JE


gameSpec : GameRoom.Spec String Int
gameSpec =
    { view =
        (\model ->
            div []
                [ text (toString model.guess)
                , button
                    [ onClick (GameRoom.Guess 0)
                    ]
                    [ text "Guess 0" ]
                ]
        )
    , isGuessCorrect = (\problem guess -> True)
    , guessEncoder = (\guess -> JE.int 0)
    , guessDecoder = (\jdVal -> 0)
    , problemEncoder = (\problem -> JE.int 0)
    , problemDecoder = (\jdVal -> "problem")
    }


main : Program Never (GameRoom.Model String Int) (GameRoom.Msg Int)
main =
    GameRoom.program gameSpec
