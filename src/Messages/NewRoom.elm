module Messages.NewRoom exposing (..)


type NewRoomMsg
    = ChangeRoomId String
    | ChangePlayerId Int String
    | AddPlayer
    | CreateRequest
    | CreateResponse String
    | RemovePlayer Int
    | DismissUrlizeNotification
