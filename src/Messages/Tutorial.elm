module Messages.Tutorial exposing (..)

import Time


type TutorialMsg problem guess
    = RequestNewProblem
    | ReceiveProblem problem
    | Guess guess
    | Tick Time.Time
