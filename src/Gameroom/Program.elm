module Program exposing (..)

import Navigation
import Models.Spec exposing (Spec)
import Models.Main exposing (Model)
import Messages exposing (Msg(..))
import Update exposing (update, cmdOnRouteChange)
import Ports
import Router
import Views exposing (view)


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
                        cmdOnRouteChange route
                in
                    ( { playerId = "alfred", room = Nothing, route = route }, cmd )
            )
        , view = view spec
        , update = update spec
        , subscriptions =
            (\model ->
                case model.route of
                    Router.Game roomId playerId Nothing ->
                        Ports.roomUpdated ReceiveUpdate

                    _ ->
                        Sub.none
            )
        }
