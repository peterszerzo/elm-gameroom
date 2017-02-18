module Gameroom.Messages exposing (..)

import Gameroom.Router as Router


type NewRoomMsg
    = ChangeRoomId String
    | ChangePlayerId Int String
    | AddPlayer
    | Submit
    | RemovePlayer Int


type GameMsg problemType guessType
    = Guess guessType
    | Tick Float
    | ReceiveUpdate String
    | ReceiveNewProblem problemType


type Msg problemType guessType
    = ReceiveGameRoomUpdate String
    | ChangeRoute (Router.Route problemType guessType)
    | GameMsgContainer (GameMsg problemType guessType)
    | NewRoomMsgContainer NewRoomMsg
    | Navigate String
