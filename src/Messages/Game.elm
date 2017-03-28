module Messages.Game exposing (..)

import Models.Room as Room


type Msg problem guess
    = Guess guess
    | Tick Float
    | ReceiveUpdate (Room.Room problem guess)
    | MarkReady
    | ReceiveNewProblem problem
