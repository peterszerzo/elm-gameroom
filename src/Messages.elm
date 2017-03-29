module Messages exposing (..)

import Router as Router
import Models.IncomingMessage as InMsg
import Models.Room as Room


type GameMsg problem guess
    = Guess guess
    | Tick Float
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


type Msg problem guess
    = ChangeRoute (Router.Route problem guess)
    | IncomingSubscription (InMsg.IncomingMessage problem guess)
    | GameMsg (GameMsg problem guess)
    | NewRoomMsg NewRoomMsg
    | Navigate String
    | NoOp
