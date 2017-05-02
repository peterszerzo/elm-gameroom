module Views exposing (view)

import Html exposing (Html, div, node, text)
import Css exposing (Stylesheet, stylesheet, position, fixed, top, px, bottom, left, right, backgroundColor)
import Html.CssHelpers
import Gameroom.Spec exposing (Spec)
import Models exposing (Model)
import Messages exposing (Msg(..))
import Router as Router
import Views.Home
import Views.Home.Styles
import Views.Header
import Views.Header.Styles
import Views.NewRoom
import Views.NewRoom.Styles
import Views.Game
import Views.Game.Styles
import Views.Scoreboard.Styles
import Views.Footer.Styles
import Views.Notification.Styles
import Css.File exposing (compile)
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
        , backgroundColor white
        ]
    ]


css : Stylesheet
css =
    stylesheet
        (Styles.Shared.styles
            ++ styles
            ++ Views.Home.Styles.styles
            ++ Views.Header.Styles.styles
            ++ Views.Scoreboard.Styles.styles
            ++ Views.Footer.Styles.styles
            ++ Views.NewRoom.Styles.styles
            ++ Views.Game.Styles.styles
            ++ Views.Notification.Styles.styles
        )


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


view : Spec problem guess -> Model problem guess -> Html (Msg problem guess)
view spec model =
    let
        content =
            case model.route of
                Router.Game game ->
                    Views.Game.view spec game
                        |> Html.map GameMsg

                Router.Home ->
                    Views.Home.view

                Router.NewRoom newRoom ->
                    Views.NewRoom.view newRoom
                        |> Html.map NewRoomMsg

                _ ->
                    div [] []
    in
        div
            [ class [ Root ]
            ]
            [ node "style" [] [ compile [ css ] |> .css |> text ]
            , Views.Header.view
            , content
            ]
