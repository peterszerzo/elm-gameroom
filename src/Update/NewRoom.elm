module Update.NewRoom exposing (..)

import Messages exposing (..)
import Models.NewRoom as NewRoom
import Utilities exposing (urlize)


update : NewRoomMsg -> NewRoom.NewRoom -> ( NewRoom.NewRoom, Bool, Maybe String )
update msg model =
    case msg of
        ChangeRoomId newRoomId ->
            let
                urlizedNewRoomId =
                    urlize newRoomId

                isChanging =
                    urlizedNewRoomId
                        /= newRoomId
            in
                ( { model
                    | roomId = urlizedNewRoomId
                    , entriesUrlized =
                        if isChanging then
                            True
                        else
                            model.entriesUrlized
                  }
                , False
                , Nothing
                )

        ChangePlayerId index newPlayerId ->
            let
                urlizedNewPlayerId =
                    urlize newPlayerId

                isChanging =
                    urlizedNewPlayerId
                        /= newPlayerId
            in
                ( { model
                    | playerIds =
                        List.indexedMap
                            (\index_ oldValue ->
                                if index_ == index then
                                    urlizedNewPlayerId
                                else
                                    oldValue
                            )
                            model.playerIds
                    , entriesUrlized =
                        if isChanging then
                            True
                        else
                            model.entriesUrlized
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

        DismissUrlizeNotification ->
            ( { model | isUrlizedNotificationDismissed = True }, False, Nothing )

        CreateResponse response ->
            ( model
            , False
            , Just
                ("/rooms/" ++ model.roomId ++ "/" ++ (model.playerIds |> List.head |> Maybe.withDefault ""))
            )
