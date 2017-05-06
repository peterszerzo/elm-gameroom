module Update.NewRoom exposing (..)

import Messages exposing (..)
import Models.NewRoom as NewRoom


update : NewRoomMsg -> NewRoom.NewRoom -> ( NewRoom.NewRoom, Bool, Maybe String )
update msg model =
    case msg of
        ChangeRoomId newRoomId ->
            ( { model | roomId = newRoomId }
            , False
            , Nothing
            )

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
            , Nothing
            )

        AddPlayer ->
            ( { model | playerIds = model.playerIds ++ [ "" ] }
            , False
            , Nothing
            )

        RemovePlayer index ->
            ( { model | playerIds = (List.take index model.playerIds) ++ (List.drop (index + 1) model.playerIds) }
            , False
            , Nothing
            )

        CreateRequest ->
            ( { model | status = NewRoom.Pending }
            , True
            , Nothing
            )

        CreateResponse response ->
            ( model
            , False
            , Just ("/rooms/" ++ model.roomId ++ "/" ++ (model.playerIds |> List.head |> Maybe.withDefault ""))
            )
