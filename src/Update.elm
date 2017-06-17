module Update exposing (..)

import Navigation
import Random
import Models.OutgoingMessage as OutgoingMessage
import Messages exposing (..)
import Messages.Tutorial
import Messages.Game
import Messages.NewRoom
import Models.Room as Room
import Models exposing (Model)
import Gameroom.Spec exposing (Spec)
import Models.Ports exposing (Ports)
import Router
import Models.IncomingMessage as InMsg
import Update.NewRoom
import Update.Game
import Update.Tutorial


cmdOnRouteChange :
    Spec problem guess
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
            Random.generate (Messages.TutorialMsg << Messages.Tutorial.ReceiveProblem) spec.problemGenerator

        ( _, _ ) ->
            Cmd.none


navigationNewUrl : Maybe String -> String -> Cmd (Msg problem guess)
navigationNewUrl baseSlug newUrl =
    baseSlug
        |> Maybe.map (\baseSlug -> "/" ++ baseSlug ++ newUrl)
        |> Maybe.withDefault newUrl
        |> Navigation.newUrl


update :
    Maybe String
    -> Spec problem guess
    -> Ports (Msg problem guess)
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Msg problem guess) )
update baseSlug spec ports msg model =
    case ( model.route, msg ) of
        ( _, Navigate newUrl ) ->
            ( model
            , navigationNewUrl baseSlug newUrl
            )

        ( oldRoute, ChangeRoute route ) ->
            ( { model | route = route }
            , Cmd.batch
                [ cmdOnRouteChange spec ports route (Just oldRoute)
                , if route == Router.NotOnBaseRoute then
                    (Navigation.newUrl
                        ("/" ++ (baseSlug |> Maybe.withDefault ""))
                    )
                  else
                    Cmd.none
                ]
            )

        ( _, Resize newWindowSize ) ->
            ( { model | windowSize = newWindowSize }, Cmd.none )

        ( Router.Game game, GameMsg gameMsg ) ->
            let
                ( newGame, cmd ) =
                    Update.Game.update spec ports gameMsg game
            in
                ( { model | route = Router.Game newGame }
                , cmd
                )

        ( Router.NewRoom newRoom, NewRoomMsg newRoomMsg ) ->
            let
                ( newNewRoom, sendSaveCommand, newUrl ) =
                    (Update.NewRoom.update newRoomMsg newRoom)
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
                    Update.NewRoom.update (Messages.NewRoom.CreateResponse "") newRoom
            in
                ( { model
                    | route =
                        Router.NewRoom newRoom
                  }
                , newUrl
                    |> Maybe.map (navigationNewUrl baseSlug)
                    |> Maybe.withDefault Cmd.none
                )

        ( Router.Game game, IncomingMessage (InMsg.RoomUpdated room) ) ->
            let
                ( newGame, cmd ) =
                    Update.Game.update spec ports (Messages.Game.ReceiveUpdate room) game
            in
                ( { model | route = Router.Game newGame }, cmd )

        ( Router.Tutorial tutorial, TutorialMsg msg ) ->
            let
                ( newTutorial, cmd ) =
                    Update.Tutorial.update spec msg tutorial
            in
                ( { model | route = Router.Tutorial newTutorial }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )
