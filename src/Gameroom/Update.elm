module Gameroom.Update exposing (..)

import Navigation
import Gameroom.Messages exposing (..)
import Gameroom.Models.Room as Room
import Gameroom.Models.Main exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Ports as Ports
import Gameroom.Router as Router
import Gameroom.Modules.NewRoom.Update as NewRoomUpdate
import Gameroom.Modules.Game.Update as GameUpdate
import Json.Encode as JE


cmdOnRouteChange :
    Router.Route problemType guessType
    -> Maybe (Router.Route problemType guessType)
    -> Cmd (Msg problemType guessType)
cmdOnRouteChange route prevRoute =
    case route of
        Router.Game game ->
            Ports.subscribeToRoom game.roomId

        _ ->
            prevRoute
                |> Maybe.andThen
                    (\rt ->
                        case rt of
                            Router.Game game ->
                                Ports.unsubscribeFromRoom game.roomId |> Just

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault Cmd.none


update : Spec problemType guessType -> Msg problemType guessType -> Model problemType guessType -> ( Model problemType guessType, Cmd (Msg problemType guessType) )
update spec msg model =
    case msg of
        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange route (Just model.route)
            )

        GameMsgContainer gameMsg ->
            case model.route of
                Router.Game game ->
                    let
                        ( newGame, cmd ) =
                            GameUpdate.update spec gameMsg game
                    in
                        ( { model | route = Router.Game newGame }
                        , cmd
                        )

                _ ->
                    ( model, Cmd.none )

        NewRoomMsgContainer newRoomMsg ->
            case model.route of
                Router.NewRoomRoute newRoom ->
                    let
                        ( newNewRoom, sendSaveCommand ) =
                            (NewRoomUpdate.update newRoomMsg newRoom)
                    in
                        ( { model | route = Router.NewRoomRoute newNewRoom }
                        , if sendSaveCommand then
                            Ports.createRoom
                                (Room.create newRoom.roomId newRoom.playerIds
                                    |> Room.encoder spec.problemEncoder spec.guessEncoder
                                    |> JE.encode 0
                                )
                          else
                            Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )

        Navigate newUrl ->
            ( model, Navigation.newUrl newUrl )