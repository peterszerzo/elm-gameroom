module Main exposing (..)

import Client exposing (..)
import Gameroom
import Models.Main exposing (Model)
import Messages exposing (Msg)


main : Program Never (Model ProblemType GuessType) (Msg ProblemType GuessType)
main =
    Gameroom.program gameSpec
