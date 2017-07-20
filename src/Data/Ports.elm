module Data.Ports exposing (..)

import Json.Encode as JE


type alias Ports msg =
    { incoming : (JE.Value -> msg) -> Sub msg
    , outgoing : JE.Value -> Cmd msg
    }


init : Ports msg
init =
    { incoming = always Sub.none
    , outgoing = always Cmd.none
    }
