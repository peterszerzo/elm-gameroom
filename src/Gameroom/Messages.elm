module Gameroom.Messages exposing (..)

import Gameroom.Router as Router
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Modules.NewRoom.Messages as NewRoomMessages
import Gameroom.Models.IncomingMessage as InMsg


-- Add C suffix for containers, standing for container
-- (abbreviation is necessary to avoid lack of readibility in the debugger)


type Msg problem guess
    = ChangeRoute (Router.Route problem guess)
    | GameMsgC (GameMessages.Msg problem guess)
    | IncomingSubscription (InMsg.IncomingMessage problem guess)
    | NewRoomMsgC NewRoomMessages.Msg
    | Navigate String
    | NoOp
