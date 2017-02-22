module Gameroom.Modules.NewRoom.Messages exposing (..)


type Msg
    = ChangeRoomId String
    | ChangePlayerId Int String
    | AddPlayer
    | CreateRequest
    | CreateResponse String
    | RemovePlayer Int
