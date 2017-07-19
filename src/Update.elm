module Update exposing (..)

import Navigation
import Random
import Messages exposing (..)
import Models exposing (Model)
import Data.Route as Route
import Data.Room as Room
import Data.Spec as Spec
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
    -> Route.Route problem guess
    -> Maybe (Route.Route problem guess)
    -> Cmd (Msg problem guess)
cmdOnRouteChange spec route prevRoute =
    let
        sendToPort =
            Spec.sendToPort spec
    in
        case ( route, prevRoute ) of
            ( Route.Game game, _ ) ->
                OutgoingMessage.SubscribeToRoom game.roomId
                    |> OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder
                    |> sendToPort

            ( _, Just (Route.Game prevGame) ) ->
                -- Unsubscribe from a previous room
                OutgoingMessage.UnsubscribeFromRoom prevGame.roomId
                    |> OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder
                    |> sendToPort

            ( Route.Tutorial _, _ ) ->
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
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Msg problem guess) )
update spec msg model =
    let
        sendToPort =
            Spec.sendToPort spec
    in
        case ( model.route, msg ) of
            ( _, Navigate newUrl ) ->
                ( model
                , navigationNewUrl spec.basePath newUrl
                )

            ( oldRoute, ChangeRoute route ) ->
                ( { model | route = route }
                , Cmd.batch
                    [ cmdOnRouteChange spec route (Just oldRoute)
                    , if route == Route.NotOnBaseRoute then
                        (Navigation.newUrl spec.basePath)
                      else
                        Cmd.none
                    ]
                )

            ( _, Resize newWindowSize ) ->
                ( { model | windowSize = newWindowSize }, Cmd.none )

            ( Route.Game game, GameMsg gameMsg ) ->
                let
                    ( newGame, commandValues, generateNewRound ) =
                        Page.Game.Update.update spec gameMsg game
                in
                    ( { model | route = Route.Game newGame }
                    , Cmd.batch <|
                        (List.map sendToPort commandValues)
                            ++ (if generateNewRound then
                                    [ (Random.generate (\pb -> Messages.GameMsg (Page.Game.Messages.ReceiveNewProblem pb)) spec.problemGenerator) ]
                                else
                                    []
                               )
                    )

            ( Route.Game game, IncomingMessage (InMsg.RoomUpdated room) ) ->
                let
                    ( newGame, commandValues, generateNewRound ) =
                        Page.Game.Update.update spec (Page.Game.Messages.ReceiveUpdate room) game
                in
                    ( { model | route = Route.Game newGame }
                    , Cmd.batch <|
                        (List.map sendToPort commandValues)
                            ++ (if generateNewRound then
                                    [ (Random.generate (\pb -> Messages.GameMsg (Page.Game.Messages.ReceiveNewProblem pb)) spec.problemGenerator) ]
                                else
                                    []
                               )
                    )

            ( Route.NewRoom newRoom, NewRoomMsg newRoomMsg ) ->
                let
                    ( newNewRoom, sendSaveCommand, newUrl ) =
                        (Page.NewRoom.Update.update newRoomMsg newRoom)
                in
                    ( { model | route = Route.NewRoom newNewRoom }
                    , if sendSaveCommand then
                        Room.create newRoom.roomId newRoom.playerIds
                            |> OutgoingMessage.CreateRoom
                            |> OutgoingMessage.encoder spec.problemEncoder spec.guessEncoder
                            |> sendToPort
                      else
                        Cmd.none
                    )

            ( Route.NewRoom newRoom, IncomingMessage (InMsg.RoomCreated room) ) ->
                let
                    ( newModel, _, newUrl ) =
                        Page.NewRoom.Update.update (Page.NewRoom.Messages.CreateResponse "") newRoom
                in
                    ( { model
                        | route =
                            Route.NewRoom newRoom
                      }
                    , newUrl
                        |> Maybe.map (navigationNewUrl spec.basePath)
                        |> Maybe.withDefault Cmd.none
                    )

            ( Route.Tutorial tutorial, TutorialMsg msg ) ->
                let
                    ( newTutorial, generateNewRound ) =
                        Page.Tutorial.Update.update spec msg tutorial
                in
                    ( { model | route = Route.Tutorial newTutorial }
                    , if generateNewRound then
                        Random.generate (Messages.TutorialMsg << Page.Tutorial.Messages.ReceiveProblem) spec.problemGenerator
                      else
                        Cmd.none
                    )

            ( _, _ ) ->
                ( model, Cmd.none )
