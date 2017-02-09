module Messages exposing (..)


type Msg guessType
    = Guess guessType
    | Disconnect
    | ReceiveUpdate String
