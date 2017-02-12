module Views.Main exposing (view)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Models.Main exposing (Model)
import Models.Spec exposing (Spec)
import Messages exposing (Msg(..), NewRoomMsg(..), GameMsg(..))
import Router
import Views.Home as Home
import Views.NewRoom
import Views.Game


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec model =
    let
        content =
            case model.route of
                Router.Game game ->
                    Views.Game.view spec game
                        |> Html.map GameMsgContainer

                Router.Home ->
                    Home.view

                Router.NewRoomRoute newRoomModel ->
                    Views.NewRoom.view newRoomModel
                        |> Html.map NewRoomMsgContainer

                _ ->
                    div [] []
    in
        div [ class "container" ]
            [ content
            ]
