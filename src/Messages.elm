module Messages exposing (..)

import Router


type Msg problemType guessType
    = Guess guessType
    | Disconnect
    | ReceiveUpdate String
    | ReceiveNewProblem problemType
    | ChangeRoute (Router.Route problemType guessType)
    | Navigate String
