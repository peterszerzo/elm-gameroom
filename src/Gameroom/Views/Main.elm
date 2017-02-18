module Gameroom.Views.Main exposing (view)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Gameroom.Models.Main exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Messages exposing (Msg(..), NewRoomMsg(..), GameMsg(..))
import Gameroom.Router as Router
import Gameroom.Views.Home as HomeView
import Gameroom.Modules.NewRoom.Views as NewRoomView
import Gameroom.Modules.Game.Views as GameView


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec model =
    let
        content =
            case model.route of
                Router.Game game ->
                    GameView.view spec game
                        |> Html.map GameMsgContainer

                Router.Home ->
                    HomeView.view

                Router.NewRoomRoute newRoomModel ->
                    NewRoomView.view newRoomModel
                        |> Html.map NewRoomMsgContainer

                _ ->
                    div [] []
    in
        div [ class "container" ]
            [ content
            ]
