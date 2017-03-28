module Messages.Main exposing (..)

import Router as Router
import Messages.Game as GameMessages
import Messages.NewRoom as NewRoomMessages
import Models.IncomingMessage as InMsg


-- Add C suffix for containers, standing for container
-- (abbreviation is necessary to avoid lack of readibility in the debugger)


type Msg problem guess
    = ChangeRoute (Router.Route problem guess)
    | GameMsgC (GameMessages.Msg problem guess)
    | IncomingSubscription (InMsg.IncomingMessage problem guess)
    | NewRoomMsgC NewRoomMessages.Msg
    | Navigate String
    | NoOp
