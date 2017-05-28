module Models.Ports exposing (..)

import Json.Encode as JE


type alias Ports msg =
    { incoming : (JE.Value -> msg) -> Sub msg
    , outgoing : JE.Value -> Cmd msg
    }
