module Views exposing (view)

import Html exposing (Html, div, node, p, a, text)
import Html.Attributes exposing (href)
import Html.CssHelpers
import Css exposing (Stylesheet, stylesheet, position, fixed, top, px, bottom, left, right, backgroundColor, hex)
import Css.Namespace exposing (namespace)
import Css.File exposing (compile)
import Router
import Data.Spec as Spec
import Models exposing (Model)
import Messages exposing (Msg(..))
import Views.Attribution
import Views.Attribution.Styles
import Views.Footer.Styles
import Views.Header
import Views.Header.Styles
import Views.Notification.Styles
import Views.Scoreboard.Styles
import Views.Timer.Styles
import Page.Game.Views
import Page.Game.Views.Styles
import Page.Home.Views
import Page.Home.Views.Styles
import Page.NewRoom.Views
import Page.NewRoom.Views.Styles
import Page.NotFound.Views
import Page.NotFound.Views.Styles
import Page.Tutorial.Views
import Page.Tutorial.Views.Styles
import Styles.Shared
import Styles.Constants exposing (white)


type CssClasses
    = Root


cssNamespace : String
cssNamespace =
    "app"


styles : List Css.Snippet
styles =
    [ Css.class Root
        [ position fixed
        , top (px 0)
        , bottom (px 0)
        , left (px 0)
        , right (px 0)
        , Css.displayFlex
        , Css.alignItems Css.center
        , Css.justifyContent Css.center
        , backgroundColor (hex white)
        ]
    ]
        |> namespace cssNamespace


css : Stylesheet
css =
    stylesheet
        (Styles.Shared.styles
            ++ styles
            ++ Views.Attribution.Styles.styles
            ++ Views.Footer.Styles.styles
            ++ Views.Header.Styles.styles
            ++ Views.Notification.Styles.styles
            ++ Views.Scoreboard.Styles.styles
            ++ Views.Timer.Styles.styles
            ++ Page.Game.Views.Styles.styles
            ++ Page.Home.Views.Styles.styles
            ++ Page.NewRoom.Views.Styles.styles
            ++ Page.NotFound.Views.Styles.styles
            ++ Page.Tutorial.Views.Styles.styles
        )


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


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
        div
            [ class [ Root ]
            ]
        <|
            [ node "style" [] [ compile [ css ] |> .css |> text ] ]
                ++ (if isHome then
                        [ Views.Attribution.view ]
                    else
                        [ Views.Header.view spec.icon
                        ]
                   )
                ++ [ content ]
