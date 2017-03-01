module Gameroom.Views.Main exposing (view)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (style, type_, value, id, for)
import Gameroom.Models.Main exposing (Model)
import Gameroom.Models.Spec exposing (Spec)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Router as Router
import Gameroom.Views.Home as HomeView
import Gameroom.Views.Header as Header
import Gameroom.Modules.NewRoom.Views as NewRoomView
import Gameroom.Modules.Game.Views as GameView
import Gameroom.Views.Styles as Styles


containerStyles : List ( String, String )
containerStyles =
    [ ( "position", "fixed" )
    , ( "top", "0" )
    , ( "bottom", "0" )
    , ( "left", "0" )
    , ( "right", "0" )
    , ( "background", Styles.white )
    ]


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
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
        div [ style containerStyles ]
            [ Header.view
            , content
            ]
