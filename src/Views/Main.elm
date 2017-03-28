module Views.Main exposing (view)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (style, type_, value, id, for)
import Gameroom.Spec exposing (Spec)
import Models.Main exposing (Model)
import Messages.Main exposing (Msg(..))
import Router as Router
import Views.Home as HomeView
import Views.Header as Header
import Views.NewRoom as NewRoomView
import Views.Game as GameView
import Views.Styles as Styles


view : Spec problem guess -> Model problem guess -> Html (Msg problem guess)
view spec model =
    let
        content =
            case model.route of
                Router.Game game ->
                    GameView.view spec game
                        |> Html.map GameMsgC

                Router.Home ->
                    HomeView.view

                Router.NewRoomRoute newRoomModel ->
                    NewRoomView.view newRoomModel
                        |> Html.map NewRoomMsgC

                _ ->
                    div [] []
    in
        div
            [ style
                [ ( "position", "fixed" )
                , ( "top", "0" )
                , ( "bottom", "0" )
                , ( "left", "0" )
                , ( "right", "0" )
                , ( "background", Styles.white )
                ]
            ]
            [ Header.view
            , content
            ]
