module Gameroom exposing (..)

import Time
import Navigation
import Models.Spec exposing (Spec)
import Models.Main exposing (Model)
import Messages exposing (Msg(..))
import Update.Main exposing (update, cmdOnRouteChange)
import Ports
import Router
import Views.Main exposing (view)


program :
    Spec problemType guessType
    -> Program Never (Model problemType guessType) (Msg problemType guessType)
program spec =
    Navigation.program (ChangeRoute << Router.parse)
        { init =
            (\loc ->
                let
                    route =
                        Router.parse loc

                    cmd =
                        cmdOnRouteChange route Nothing
                in
                    ( { route = route }, cmd )
            )
        , view = view spec
        , update = update spec
        , subscriptions =
            (\model ->
                Sub.batch
                    [ Ports.roomUpdated ReceiveGameRoomUpdate
                    , case model.route of
                        Router.Game _ ->
                            Time.every (50 * Time.millisecond) (\t -> GameMsgContainer (Messages.Tick t))

                        _ ->
                            Sub.none
                    ]
            )
        }
