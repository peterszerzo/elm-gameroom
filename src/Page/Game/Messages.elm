module Page.Game.Messages exposing (..)

import Time
import Data.Room as Room


type Msg problem guess
    = Guess guess
    | Tick Time.Time
    | ReceiveUpdate (Room.Room problem guess)
    | MarkReady
    | ReceiveNewProblem problem
