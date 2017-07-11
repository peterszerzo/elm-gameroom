module Constants exposing (..)


nullString : String
nullString =
    -- If a value (room data, player data) doesn't exist in storage, this string is inserted instead. This is necessary because some storage services like Firebase are weird with non-existent values while retrieving data.
    "__elm-gameroom__null__"
