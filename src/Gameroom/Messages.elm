module Gameroom.Messages exposing (..)

import Gameroom.Router as Router
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Modules.NewRoom.Messages as NewRoomMessages


type Msg problemType guessType
    = ChangeRoute (Router.Route problemType guessType)
    | GameMsgContainer (GameMessages.Msg problemType guessType)
    | NewRoomMsgContainer NewRoomMessages.Msg
    | Navigate String
