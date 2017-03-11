module Gameroom.Update exposing (..)

import Navigation
import Gameroom.Commands as Commands
import Gameroom.Messages exposing (..)
import Gameroom.Models.Room as Room
import Gameroom.Models.Main exposing (Model)
import Gameroom.Spec exposing (Spec)
import Gameroom.Models.Ports exposing (Ports)
import Gameroom.Router as Router
import Gameroom.Modules.NewRoom.Update as NewRoomUpdate
import Gameroom.Modules.Game.Update as GameUpdate
import Gameroom.Models.IncomingMessage as InMsg
import Gameroom.Modules.NewRoom.Messages as NewRoomMsg
import Gameroom.Modules.Game.Messages as GameMsg
import Json.Encode as JE


cmdOnRouteChange :
    Spec problem guess
    -> Ports (Msg problem guess)
    -> Router.Route problem guess
    -> Maybe (Router.Route problem guess)
    -> Cmd (Msg problem guess)
cmdOnRouteChange spec ports route prevRoute =
    case route of
        Router.Game game ->
            Commands.SubscribeToRoom game.roomId
                |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                |> JE.encode 0
                |> ports.outgoing

        _ ->
            prevRoute
                |> Maybe.andThen
                    (\rt ->
                        case rt of
                            Router.Game game ->
                                Commands.UnsubscribeFromRoom game.roomId
                                    |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                                    |> JE.encode 0
                                    |> ports.outgoing
                                    |> Just

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault Cmd.none


update : Spec problem guess -> Ports (Msg problem guess) -> Msg problem guess -> Model problem guess -> ( Model problem guess, Cmd (Msg problem guess) )
update spec ports msg model =
    case msg of
        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange spec ports route (Just model.route)
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
                            Room.create newRoom.roomId newRoom.playerIds
                                |> Commands.CreateRoom
                                |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                                |> JE.encode 0
                                |> ports.outgoing
                          else
                            Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )

        Navigate newUrl ->
            ( model, Navigation.newUrl newUrl )

        IncomingSubscription inMsg ->
            case inMsg of
                InMsg.RoomCreated room ->
                    case model.route of
                        Router.NewRoomRoute newRoom ->
                            ( { model | route = NewRoomUpdate.update (NewRoomMsg.CreateResponse "") newRoom |> Tuple.first |> Router.NewRoomRoute }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                InMsg.RoomUpdated room ->
                    case model.route of
                        Router.Game game ->
                            let
                                ( newGame, cmd ) =
                                    GameUpdate.update spec ports (GameMsg.ReceiveUpdate room) game
                            in
                                ( { model | route = Router.Game newGame }, cmd )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
