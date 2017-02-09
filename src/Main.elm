module Main exposing (..)

import Html exposing (Html, beginnerProgram, div, button, text)
import Html.Events exposing (onClick)
import GameRoom
import Json.Encode as JE
import Json.Decode as JD


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
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , guessEncoder = (JE.int)
    , guessDecoder = (JD.int)
    , problemEncoder = (JE.string)
    , problemDecoder = (JD.string)
    }


main : Program Never (GameRoom.Model String Int) (GameRoom.Msg Int)
main =
    GameRoom.program gameSpec
