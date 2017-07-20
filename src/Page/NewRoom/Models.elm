module Page.NewRoom.Models exposing (..)


type Status
    = Editing
    | Pending
    | Error


type alias Model =
    { roomId : String
    , playerIds : List String
    , status : Status
    , entriesUrlized : Bool
    , isUrlizedNotificationDismissed : Bool
    }


init : Model
init =
    Model "" [ "", "" ] Editing False False
