module Gameroom.Update.Main exposing (..)

import Random
import Navigation
import Gameroom.Messages exposing (..)
import Gameroom.Models.Room as Room
import Gameroom.Models.Main exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Ports as Ports
import Gameroom.Router as Router
import Gameroom.Modules.NewRoom.Update as NewRoomUpdate
import Gameroom.Modules.Game.Update as GameUpdate
import Gameroom.Modules.Game.Messages as GameMessages
import Json.Encode as JE


cmdOnRouteChange : Router.Route problemType guessType -> Maybe (Router.Route problemType guessType) -> Cmd (Msg problemType guessType)
cmdOnRouteChange route maybePreviousRoute =
    case route of
        Router.Game game ->
            Ports.subscribeToRoom game.roomId

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
                            Router.Game (GameUpdate.update spec (GameMessages.ReceiveUpdate roomString) game)

                        _ ->
                            model.route
            in
                ( { model | route = newRoute }, Random.generate (\pb -> GameMsgContainer (GameMessages.ReceiveNewProblem pb)) spec.problemGenerator )

        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange route (Just model.route)
            )

        GameMsgContainer gameMsg ->
            ( { model
                | route =
                    case model.route of
                        Router.Game game ->
                            Router.Game (GameUpdate.update spec gameMsg game)

                        _ ->
                            model.route
              }
            , Cmd.none
            )

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
