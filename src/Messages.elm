module Messages exposing (..)

import Router as Router
import Models.IncomingMessage as InMsg
import Messages.Tutorial
import Messages.Game
import Messages.NewRoom
import Window


type Msg problem guess
    = ChangeRoute (Router.Route problem guess)
    | IncomingMessage (InMsg.IncomingMessage problem guess)
    | GameMsg (Messages.Game.GameMsg problem guess)
    | NewRoomMsg Messages.NewRoom.NewRoomMsg
    | TutorialMsg (Messages.Tutorial.TutorialMsg problem guess)
    | Navigate String
    | Resize Window.Size
    | NoOp
