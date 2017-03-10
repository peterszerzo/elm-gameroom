module Gameroom.Modules.Game.Messages exposing (..)


type Msg problem guess
    = Guess guess
    | Tick Float
    | ReceiveUpdate String
    | MarkReady
    | ReceiveNewProblem problem
