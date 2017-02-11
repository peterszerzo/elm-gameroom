module Messages exposing (..)

import Router


type NewRoomMsg
    = ChangeRoomId String
    | ChangePlayerId Int String
    | AddPlayer
    | RemovePlayer Int


type Msg problemType guessType
    = Guess guessType
    | Disconnect
    | ReceiveUpdate String
    | ReceiveNewProblem problemType
    | ChangeRoute (Router.Route problemType guessType)
    | NewRoomMsgContainer NewRoomMsg
    | Navigate String
