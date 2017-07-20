module Page.Tutorial.Messages exposing (..)

import Time


type Msg problem guess
    = RequestNewProblem
    | ReceiveProblem problem
    | Guess guess
    | Tick Time.Time
