module Models.NewRoom exposing (..)


type NewRoomStatus
    = Editing
    | Pending
    | Success
    | Error


type alias NewRoom =
    { roomId : String
    , playerIds : List String
    , status : NewRoomStatus
    }


init : NewRoom
init =
    NewRoom "" [ "", "" ] Editing
