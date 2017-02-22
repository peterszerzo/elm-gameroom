module Gameroom.Modules.Game.Messages exposing (..)


type Msg problemType guessType
    = Guess guessType
    | Tick Float
    | ReceiveUpdate String
    | MarkReady
    | ReceiveNewProblem problemType
