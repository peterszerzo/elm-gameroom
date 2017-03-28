module Update.Main exposing (..)

import Navigation
import Commands as Commands
import Messages.Main exposing (..)
import Models.Room as Room
import Models.Main exposing (Model)
import Gameroom.Spec exposing (Spec)
import Models.Ports exposing (Ports)
import Router as Router
import Update.NewRoom as NewRoomUpdate
import Update.Game as GameUpdate
import Models.IncomingMessage as InMsg
import Messages.NewRoom as NewRoomMsg
import Messages.Game as GameMsg
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


update :
    Spec problem guess
    -> Ports (Msg problem guess)
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Msg problem guess) )
update spec ports msg model =
    case ( model.route, msg ) of
        ( _, Navigate newUrl ) ->
            ( model, Navigation.newUrl newUrl )

        ( oldRoute, ChangeRoute route ) ->
            ( { model | route = route }
            , cmdOnRouteChange spec ports route (Just oldRoute)
            )

        ( Router.Game game, GameMsgC gameMsg ) ->
            let
                ( newGame, cmd ) =
                    GameUpdate.update spec ports gameMsg game
            in
                ( { model | route = Router.Game newGame }
                , cmd
                )

        ( Router.NewRoom newRoom, NewRoomMsgC newRoomMsg ) ->
            let
                ( newNewRoom, sendSaveCommand ) =
                    (NewRoomUpdate.update newRoomMsg newRoom)
            in
                ( { model | route = Router.NewRoom newNewRoom }
                , if sendSaveCommand then
                    Room.create newRoom.roomId newRoom.playerIds
                        |> Commands.CreateRoom
                        |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                        |> JE.encode 0
                        |> ports.outgoing
                  else
                    Cmd.none
                )

        ( Router.NewRoom newRoom, IncomingSubscription (InMsg.RoomCreated room) ) ->
            ( { model
                | route =
                    NewRoomUpdate.update (NewRoomMsg.CreateResponse "") newRoom
                        |> Tuple.first
                        |> Router.NewRoom
              }
            , Cmd.none
            )

        ( Router.Game game, IncomingSubscription (InMsg.RoomUpdated room) ) ->
            let
                ( newGame, cmd ) =
                    GameUpdate.update spec ports (GameMsg.ReceiveUpdate room) game
            in
                ( { model | route = Router.Game newGame }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )
