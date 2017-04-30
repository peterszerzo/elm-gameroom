module Update.NewRoom exposing (..)

import Messages exposing (..)
import Models.NewRoom as NewRoom


update : NewRoomMsg -> NewRoom.NewRoom -> ( NewRoom.NewRoom, Bool )
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

        CreateRequest ->
            ( { model | status = NewRoom.Pending }, True )

        CreateResponse response ->
            ( { model | status = NewRoom.Success }, False )
