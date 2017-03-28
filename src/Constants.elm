module Constants exposing (..)

import Time


-- Null string value used in storage


nullString : String
nullString =
    "__elm-gameroom__null__"



-- Game round time parameters, all in milliseconds


gameTick : Float
gameTick =
    50 * Time.millisecond


roundDuration : Float
roundDuration =
    3000 * Time.millisecond


cooldownDuration : Float
cooldownDuration =
    4000 * Time.millisecond
