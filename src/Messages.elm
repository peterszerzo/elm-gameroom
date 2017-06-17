module Messages exposing (..)

import Router as Router
import Models.IncomingMessage as InMsg
import Models.Room as Room
import Messages.Tutorial
import Window
import Time


type GameMsg problem guess
    = Guess guess
    | Tick Time.Time
    | ReceiveUpdate (Room.Room problem guess)
    | MarkReady
    | ReceiveNewProblem problem


type NewRoomMsg
    = ChangeRoomId String
    | ChangePlayerId Int String
    | AddPlayer
    | CreateRequest
    | CreateResponse String
    | RemovePlayer Int
    | DismissUrlizeNotification


type Msg problem guess
    = ChangeRoute (Router.Route problem guess)
    | IncomingSubscription (InMsg.IncomingMessage problem guess)
    | GameMsg (GameMsg problem guess)
    | NewRoomMsg NewRoomMsg
    | TutorialMsg (Messages.Tutorial.Msg problem guess)
    | Navigate String
    | Resize Window.Size
    | NoOp
