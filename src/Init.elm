module Init exposing (..)

import Router
import Window
import Navigation
import Task
import Models exposing (Model)
import Models.Ports exposing (Ports)
import Models.Spec as Spec
import Messages exposing (Msg)
import Update exposing (cmdOnRouteChange)


init :
    Spec.DetailedSpec problem guess
    -> Ports (Msg problem guess)
    -> Navigation.Location
    -> ( Model problem guess, Cmd (Messages.Msg problem guess) )
init spec ports loc =
    let
        route =
            Router.parse spec.baseUrl loc

        cmd =
            Cmd.batch
                [ cmdOnRouteChange spec ports route Nothing
                , Window.size |> Task.perform Messages.Resize
                , if route == Router.NotOnBaseRoute then
                    (Navigation.newUrl
                        ("/" ++ (spec.baseUrl |> Maybe.withDefault ""))
                    )
                  else
                    Cmd.none
                ]
    in
        ( { route = route
          , windowSize = Window.Size 0 0
          }
        , cmd
        )
