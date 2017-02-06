port module Ports exposing (..)


port disconnect : (String -> msg) -> Sub msg


port reconnect : (String -> msg) -> Sub msg


port create : String -> Cmd msg


port created : (String -> msg) -> Sub msg


port update : String -> Cmd msg


port updated : (String -> msg) -> Sub msg
