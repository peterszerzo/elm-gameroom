module Gameroom.Messages exposing (..)

import Gameroom.Router as Router
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Modules.NewRoom.Messages as NewRoomMessages


-- Add C suffix for containers, standing for container
-- (abbreviation is necessary to avoid lack of readibility in the debugger)


type Msg problem guess
    = ChangeRoute (Router.Route problem guess)
    | GameMsgC (GameMessages.Msg problem guess)
    | NewRoomMsgC NewRoomMessages.Msg
    | Navigate String
