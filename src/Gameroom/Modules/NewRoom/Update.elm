module Gameroom.Modules.NewRoom.Update exposing (..)

import Gameroom.Messages exposing (..)
import Gameroom.Modules.NewRoom.Models as NewRoom


update : NewRoomMsg -> NewRoom.Model -> NewRoom.Model
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
