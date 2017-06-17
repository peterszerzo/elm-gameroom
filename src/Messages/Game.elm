module Messages.Game exposing (..)

import Time
import Models.Room as Room


type GameMsg problem guess
    = Guess guess
    | Tick Time.Time
    | ReceiveUpdate (Room.Room problem guess)
    | MarkReady
    | ReceiveNewProblem problem
