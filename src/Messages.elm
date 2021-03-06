module Messages exposing (..)

import Window
import Data.Route exposing (Route)
import Data.IncomingMessage as InMsg
import Page.Tutorial.Messages
import Page.Game.Messages
import Page.NewRoom.Messages


type Msg problem guess
    = ChangeRoute (Route problem guess)
    | IncomingMessage (InMsg.IncomingMessage problem guess)
    | GameMsg (Page.Game.Messages.Msg problem guess)
    | NewRoomMsg Page.NewRoom.Messages.Msg
    | TutorialMsg (Page.Tutorial.Messages.Msg problem guess)
    | Navigate String
    | Resize Window.Size
    | NoOp
