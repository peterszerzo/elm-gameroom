module Constants exposing (..)

import Time exposing (Time, millisecond)


-- Null string value used in storage


nullString : String
nullString =
    "__elm-gameroom__null__"



-- Game round time parameters, all in milliseconds


ticksInRound : Int
ticksInRound =
    40


ticksInCooldown : Int
ticksInCooldown =
    20


tickDuration : Time
tickDuration =
    100 * millisecond
