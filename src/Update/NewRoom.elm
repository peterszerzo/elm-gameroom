module Update.NewRoom exposing (..)

import Messages exposing (..)
import Models.NewRoom as NewRoom


update : NewRoomMsg -> NewRoom.NewRoom -> NewRoom.NewRoom
update msg model =
    case msg of
        ChangeRoomId newRoomId ->
            { model | roomId = newRoomId }

        ChangePlayerId index value ->
            { model
                | playerIds =
                    List.indexedMap
                        (\index_ oldValue ->
                            if index_ == index then
                                value
                            else
                                oldValue
                        )
                        model.playerIds
            }

        AddPlayer ->
            { model | playerIds = model.playerIds ++ [ "" ] }

        _ ->
            model
