module Constants exposing (..)


debugMode : Bool
debugMode =
    False



-- Null string value used in storage


nullString : String
nullString =
    "__elm-gameroom__null__"



-- Game round time parameters, all in milliseconds


ticksInRound : Int
ticksInRound =
    if debugMode then
        10
    else
        100


ticksInCooldown : Int
ticksInCooldown =
    if debugMode then
        5
    else
        50
