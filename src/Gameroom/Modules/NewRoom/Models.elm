module Gameroom.Modules.NewRoom.Models exposing (..)


type Status
    = Editing
    | Pending
    | Success
    | Error


type alias Model =
    { roomId : String
    , playerIds : List String
    , status : Status
    }


init : Model
init =
    Model "" [ "", "" ] Editing
