module Models.NewRoom exposing (..)


type NewRoomStatus
    = Editing
    | Pending
    | Error


type alias NewRoom =
    { roomId : String
    , playerIds : List String
    , status : NewRoomStatus
    , entriesUrlized : Bool
    , isUrlizedNotificationDismissed : Bool
    }


init : NewRoom
init =
    NewRoom "" [ "", "" ] Editing False False
