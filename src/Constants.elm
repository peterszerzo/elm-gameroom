module Constants exposing (..)

-- Null string value used in storage


nullString : String
nullString =
    "__elm-gameroom__null__"



-- Game round time parameters, all in milliseconds


ticksInRound : Int
ticksInRound =
    1000


ticksInCooldown : Int
ticksInCooldown =
    500
