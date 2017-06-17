module Constants exposing (..)

import Time exposing (Time, millisecond, second)


-- Null string value used in storage


nullString : String
nullString =
    "__elm-gameroom__null__"



-- Game round time parameters, all in milliseconds


roundDuration : Time
roundDuration =
    4 * second


cooldownDuration : Time
cooldownDuration =
    2 * second
