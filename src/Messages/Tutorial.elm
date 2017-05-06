module Messages.Tutorial exposing (..)


type Msg problem guess
    = RequestNewProblem
    | ReceiveProblem problem
    | Guess guess
    | AnimationTick Float
