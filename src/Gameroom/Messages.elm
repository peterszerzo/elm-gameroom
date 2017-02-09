module Messages exposing (..)

import Router


type Msg problemType guessType
    = Guess guessType
    | Disconnect
    | ReceiveUpdate String
    | ChangeRoute (Router.Route problemType guessType)
    | Navigate String
