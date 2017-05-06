module Messages.Tutorial exposing (..)


type Msg problem guess
    = ClickAnywhere
    | ReceiveProblem problem
    | Guess guess
    | AnimationTick Float
