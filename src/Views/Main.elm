module Views.Main exposing (view)

import Html exposing (Html, div, node, text)
import Html.CssHelpers
import Gameroom.Spec exposing (Spec)
import Models.Main exposing (Model)
import Messages exposing (Msg(..))
import Router as Router
import Views.Home as HomeView
import Views.Header as Header
import Views.NewRoom as NewRoomView
import Views.Game as GameView
import Css.File exposing (compile)
import Styles


{ class } =
    Html.CssHelpers.withNamespace ""


view : Spec problem guess -> Model problem guess -> Html (Msg problem guess)
view spec model =
    let
        content =
            case model.route of
                Router.Game game ->
                    GameView.view spec game
                        |> Html.map GameMsg

                Router.Home ->
                    HomeView.view

                Router.NewRoom newRoom ->
                    NewRoomView.view newRoom
                        |> Html.map NewRoomMsg

                _ ->
                    div [] []
    in
        div
            [ class [ Styles.App ]
            ]
            [ node "style" [] [ compile [ Styles.css ] |> .css |> text ]
            , Header.view
            , content
            ]
