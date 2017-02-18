module Gameroom.Modules.NewRoom.Update exposing (..)

import Gameroom.Messages exposing (..)
import Gameroom.Modules.NewRoom.Models as NewRoom


update : NewRoomMsg -> NewRoom.Model -> ( NewRoom.Model, Bool )
update msg model =
    case msg of
        ChangeRoomId newRoomId ->
            ( { model | roomId = newRoomId }, False )

        ChangePlayerId index value ->
            ( { model
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
            , False
            )

        AddPlayer ->
            ( { model | playerIds = model.playerIds ++ [ "" ] }, False )

        RemovePlayer index ->
            ( { model | playerIds = (List.take index model.playerIds) ++ (List.drop (index + 1) model.playerIds) }, False )

        Submit ->
            ( { model | status = NewRoom.Pending }, True )
