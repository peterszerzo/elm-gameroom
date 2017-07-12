module Views exposing (view)

import Html exposing (Html, div, node, p, a, text)
import Html.Attributes exposing (href)
import Router
import Data.Spec as Spec
import Models exposing (Model)
import Messages exposing (Msg(..))
import Page.Game.Views
import Page.Home.Views
import Page.NewRoom.Views
import Page.NotFound.Views
import Page.Tutorial.Views
import Views.Layout


view : Spec.DetailedSpec problem guess -> Model problem guess -> Html (Msg problem guess)
view spec model =
    let
        isHome =
            model.route == Router.Home

        content =
            case model.route of
                Router.Home ->
                    Page.Home.Views.view spec

                Router.Game game ->
                    Page.Game.Views.view spec model.windowSize game
                        |> Html.map GameMsg

                Router.NewRoom newRoom ->
                    Page.NewRoom.Views.view newRoom
                        |> Html.map NewRoomMsg

                Router.NotFound ->
                    Page.NotFound.Views.view

                Router.NotOnBaseRoute ->
                    div []
                        [ p [] [ text "Not on configured base path. Redirecting.." ]
                        , p []
                            [ text "If not redirected in a couple of seconds, "
                            , a [ href spec.basePath ] [ text "click here" ]
                            , text "."
                            ]
                        ]

                Router.Tutorial tutorial ->
                    Page.Tutorial.Views.view spec model.windowSize tutorial
                        |> Html.map TutorialMsg
    in
        Views.Layout.view isHome spec.icon [ content ]
