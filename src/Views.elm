module Views exposing (view)

import Html exposing (Html, div, node, text)
import Css exposing (Stylesheet, stylesheet, position, fixed, top, px, bottom, left, right, backgroundColor, hex)
import Css.Namespace exposing (namespace)
import Html.CssHelpers
import Css.File exposing (compile)
import Gameroom.Spec exposing (Spec)
import Models exposing (Model)
import Messages exposing (Msg(..))
import Router as Router
import Views.Attribution
import Views.Attribution.Styles
import Views.Footer.Styles
import Views.Game
import Views.Game.Styles
import Views.Header
import Views.Header.Styles
import Views.Home
import Views.Home.Styles
import Views.NewRoom
import Views.NewRoom.Styles
import Views.NotFound
import Views.NotFound.Styles
import Views.Notification.Styles
import Views.Scoreboard.Styles
import Views.Timer.Styles
import Views.Tutorial
import Views.Tutorial.Styles
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
            ++ Views.Game.Styles.styles
            ++ Views.Header.Styles.styles
            ++ Views.Home.Styles.styles
            ++ Views.NewRoom.Styles.styles
            ++ Views.NotFound.Styles.styles
            ++ Views.Notification.Styles.styles
            ++ Views.Scoreboard.Styles.styles
            ++ Views.Timer.Styles.styles
            ++ Views.Tutorial.Styles.styles
        )


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


view : Maybe String -> Spec problem guess -> Model problem guess -> Html (Msg problem guess)
view baseSlug spec model =
    let
        isHome =
            model.route == Router.Home

        content =
            case model.route of
                Router.Home ->
                    Views.Home.view spec

                Router.Game game ->
                    Views.Game.view baseSlug spec model.windowSize game
                        |> Html.map GameMsg

                Router.NewRoom newRoom ->
                    Views.NewRoom.view newRoom
                        |> Html.map NewRoomMsg

                Router.NotFound ->
                    Views.NotFound.view

                Router.NotOnBaseRoute ->
                    div [] []

                Router.Tutorial tutorial ->
                    Views.Tutorial.view spec model.windowSize tutorial
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
                        [ Views.Header.view spec.copy.icon
                        ]
                   )
                ++ [ content ]
