module Main exposing (..)

import Client exposing (..)
import Gameroom exposing (program, Model, Msg)


main : Program Never (Model ProblemType GuessType) (Msg ProblemType GuessType)
main =
    Gameroom.program gameSpec
