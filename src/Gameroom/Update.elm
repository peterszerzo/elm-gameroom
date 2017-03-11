module Gameroom.Update exposing (..)

import Navigation
import Gameroom.Commands
import Gameroom.Messages exposing (..)
import Gameroom.Models.Room as Room
import Gameroom.Models.Main exposing (Model)
import Gameroom.Spec exposing (Spec)
import Gameroom.Ports exposing (Ports)
import Gameroom.Router as Router
import Gameroom.Modules.NewRoom.Update as NewRoomUpdate
import Gameroom.Modules.Game.Update as GameUpdate
import Json.Encode as JE


cmdOnRouteChange :
    Ports (Msg problem guess)
    -> Router.Route problem guess
    -> Maybe (Router.Route problem guess)
    -> Cmd (Msg problem guess)
cmdOnRouteChange ports route prevRoute =
    case route of
        Router.Game game ->
            ports.subscribeToRoom game.roomId

        _ ->
            prevRoute
                |> Maybe.andThen
                    (\rt ->
                        case rt of
                            Router.Game game ->
                                ports.unsubscribeFromRoom game.roomId |> Just

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault Cmd.none


update : Spec problem guess -> Ports (Msg problem guess) -> Msg problem guess -> Model problem guess -> ( Model problem guess, Cmd (Msg problem guess) )
update spec ports msg model =
    case msg of
        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange ports route (Just model.route)
            )

        GameMsgC gameMsg ->
            case model.route of
                Router.Game game ->
                    let
                        ( newGame, cmd ) =
                            GameUpdate.update spec ports gameMsg game
                    in
                        ( { model | route = Router.Game newGame }
                        , cmd
                        )

                _ ->
                    ( model, Cmd.none )

        NewRoomMsgC newRoomMsg ->
            case model.route of
                Router.NewRoomRoute newRoom ->
                    let
                        ( newNewRoom, sendSaveCommand ) =
                            (NewRoomUpdate.update newRoomMsg newRoom)
                    in
                        ( { model | route = Router.NewRoomRoute newNewRoom }
                        , if sendSaveCommand then
                            Cmd.batch
                                [ ports.createRoom
                                    (Room.create newRoom.roomId newRoom.playerIds
                                        |> Room.encoder spec.problemEncoder spec.guessEncoder
                                        |> JE.encode 0
                                    )
                                , Room.create newRoom.roomId newRoom.playerIds
                                    |> Gameroom.Commands.CreateRoom
                                    |> Gameroom.Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                                    |> JE.encode 0
                                    |> ports.outgoing
                                ]
                          else
                            Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )

        Navigate newUrl ->
            ( model, Navigation.newUrl newUrl )
