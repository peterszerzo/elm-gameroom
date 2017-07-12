module Update exposing (..)

import Navigation
import Random
import Router
import Messages exposing (..)
import Models exposing (Model)
import Data.Room as Room
import Data.Spec as Spec
import Data.Ports exposing (Ports)
import Data.IncomingMessage as InMsg
import Data.OutgoingMessage as OutgoingMessage
import Page.Game.Messages
import Page.Game.Update
import Page.NewRoom.Messages
import Page.NewRoom.Update
import Page.Tutorial.Messages
import Page.Tutorial.Update


cmdOnRouteChange :
    Spec.DetailedSpec problem guess
    -> Ports (Msg problem guess)
    -> Router.Route problem guess
    -> Maybe (Router.Route problem guess)
    -> Cmd (Msg problem guess)
cmdOnRouteChange spec ports route prevRoute =
    case ( route, prevRoute ) of
        ( Router.Game game, _ ) ->
            OutgoingMessage.SubscribeToRoom game.roomId
                |> OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder
                |> ports.outgoing

        ( _, Just (Router.Game prevGame) ) ->
            -- Unsubscribe from a previous room
            OutgoingMessage.UnsubscribeFromRoom prevGame.roomId
                |> OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder
                |> ports.outgoing

        ( Router.Tutorial _, _ ) ->
            Random.generate (Messages.TutorialMsg << Page.Tutorial.Messages.ReceiveProblem) spec.problemGenerator

        ( _, _ ) ->
            Cmd.none


navigationNewUrl : String -> String -> Cmd (Msg problem guess)
navigationNewUrl basePath newUrl =
    basePath
        ++ newUrl
        |> Navigation.newUrl


update :
    Spec.DetailedSpec problem guess
    -> Ports (Msg problem guess)
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Msg problem guess) )
update spec ports msg model =
    case ( model.route, msg ) of
        ( _, Navigate newUrl ) ->
            ( model
            , navigationNewUrl spec.basePath newUrl
            )

        ( oldRoute, ChangeRoute route ) ->
            ( { model | route = route }
            , Cmd.batch
                [ cmdOnRouteChange spec ports route (Just oldRoute)
                , if route == Router.NotOnBaseRoute then
                    (Navigation.newUrl spec.basePath)
                  else
                    Cmd.none
                ]
            )

        ( _, Resize newWindowSize ) ->
            ( { model | windowSize = newWindowSize }, Cmd.none )

        ( Router.Game game, GameMsg gameMsg ) ->
            let
                ( newGame, cmd ) =
                    Page.Game.Update.update spec ports gameMsg game
            in
                ( { model | route = Router.Game newGame }
                , cmd
                )

        ( Router.NewRoom newRoom, NewRoomMsg newRoomMsg ) ->
            let
                ( newNewRoom, sendSaveCommand, newUrl ) =
                    (Page.NewRoom.Update.update newRoomMsg newRoom)
            in
                ( { model | route = Router.NewRoom newNewRoom }
                , if sendSaveCommand then
                    Room.create newRoom.roomId newRoom.playerIds
                        |> OutgoingMessage.CreateRoom
                        |> OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder
                        |> ports.outgoing
                  else
                    Cmd.none
                )

        ( Router.NewRoom newRoom, IncomingMessage (InMsg.RoomCreated room) ) ->
            let
                ( newModel, _, newUrl ) =
                    Page.NewRoom.Update.update (Page.NewRoom.Messages.CreateResponse "") newRoom
            in
                ( { model
                    | route =
                        Router.NewRoom newRoom
                  }
                , newUrl
                    |> Maybe.map (navigationNewUrl spec.basePath)
                    |> Maybe.withDefault Cmd.none
                )

        ( Router.Game game, IncomingMessage (InMsg.RoomUpdated room) ) ->
            let
                ( newGame, cmd ) =
                    Page.Game.Update.update spec ports (Page.Game.Messages.ReceiveUpdate room) game
            in
                ( { model | route = Router.Game newGame }, cmd )

        ( Router.Tutorial tutorial, TutorialMsg msg ) ->
            let
                ( newTutorial, cmd ) =
                    Page.Tutorial.Update.update spec msg tutorial
            in
                ( { model | route = Router.Tutorial newTutorial }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )
