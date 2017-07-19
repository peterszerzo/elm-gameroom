module Views exposing (view)

import Html exposing (Html, div, node, p, a, text)
import Html.Attributes exposing (href)
import Data.Route as Route
import Data.Spec as Spec
import Models exposing (Model)
import Messages exposing (Msg(..))
import Page.Game.Views
import Page.Home.Views
import Page.NewRoom.Views
import Page.NotFound.Views
import Page.Tutorial.Views
import Views.Layout
import Views.NoMultiplayer


view : Spec.DetailedSpec problem guess -> Model problem guess -> Html (Msg problem guess)
view spec model =
    let
        isHome =
            model.route == Route.Home

        noMultiplayer =
            spec.ports == Nothing

        content =
            case model.route of
                Route.Home ->
                    Page.Home.Views.view spec

                Route.Game game ->
                    if noMultiplayer then
                        Views.NoMultiplayer.view
                    else
                        Page.Game.Views.view spec model.windowSize game
                            |> Html.map GameMsg

                Route.NewRoom newRoom ->
                    if noMultiplayer then
                        Views.NoMultiplayer.view
                    else
                        Page.NewRoom.Views.view newRoom
                            |> Html.map NewRoomMsg

                Route.NotFound ->
                    Page.NotFound.Views.view

                Route.NotOnBaseRoute ->
                    div []
                        [ p [] [ text "Not on configured base path. Redirecting.." ]
                        , p []
                            [ text "If not redirected in a couple of seconds, "
                            , a [ href spec.basePath ] [ text "click here" ]
                            , text "."
                            ]
                        ]

                Route.Tutorial tutorial ->
                    Page.Tutorial.Views.view spec model.windowSize tutorial
                        |> Html.map TutorialMsg
    in
        Views.Layout.view spec.inlineStyle isHome spec.unicodeIcon [ content ]
