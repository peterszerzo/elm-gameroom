module Init exposing (..)

import Router
import Window
import Navigation
import Task
import Models exposing (Model)
import Models.Ports exposing (Ports)
import Gameroom.Spec exposing (Spec)
import Messages exposing (Msg)
import Update exposing (cmdOnRouteChange)


init :
    Spec problem guess
    -> Ports (Msg problem guess)
    -> Navigation.Location
    -> ( Model problem guess, Cmd (Messages.Msg problem guess) )
init spec ports loc =
    let
        route =
            Router.parse loc

        cmd =
            Cmd.batch
                [ cmdOnRouteChange spec ports route Nothing
                , Window.size |> Task.perform Messages.Resize
                ]
    in
        ( { route = route
          , windowSize = Window.Size 0 0
          }
        , cmd
        )
