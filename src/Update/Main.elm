module Update.Main exposing (..)

import Random
import Navigation
import Messages exposing (..)
import Models.Main exposing (Model)
import Models.Spec exposing (Spec)
import Ports
import Router
import Update.NewRoom
import Update.Game


cmdOnRouteChange : Router.Route problemType guessType -> Maybe (Router.Route problemType guessType) -> Cmd (Msg problemType guessType)
cmdOnRouteChange route maybePreviousRoute =
    case route of
        Router.Game game ->
            Ports.connectToRoom game.roomId

        _ ->
            Cmd.none


update : Spec problemType guessType -> Msg problemType guessType -> Model problemType guessType -> ( Model problemType guessType, Cmd (Msg problemType guessType) )
update spec msg model =
    case msg of
        ReceiveGameRoomUpdate roomString ->
            let
                newRoute =
                    case model.route of
                        Router.Game game ->
                            Router.Game (Update.Game.update spec (ReceiveUpdate roomString) game)

                        _ ->
                            model.route
            in
                ( { model | route = newRoute }, Random.generate (\pb -> GameMsgContainer (ReceiveNewProblem pb)) spec.problemGenerator )

        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange route (Just model.route)
            )

        GameMsgContainer gameMsg ->
            ( { model
                | route =
                    case model.route of
                        Router.Game game ->
                            Router.Game (Update.Game.update spec gameMsg game)

                        _ ->
                            model.route
              }
            , Cmd.none
            )

        NewRoomMsgContainer newRoomMsg ->
            ( { model
                | route =
                    case model.route of
                        Router.NewRoomRoute newRoom ->
                            Router.NewRoomRoute (Update.NewRoom.update newRoomMsg newRoom)

                        _ ->
                            model.route
              }
            , Cmd.none
            )

        Navigate newUrl ->
            ( model, Navigation.newUrl newUrl )
