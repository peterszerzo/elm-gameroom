module Views.Main exposing (view)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Models.Main exposing (Model)
import Models.Spec exposing (Spec)
import Messages exposing (Msg(..), NewRoomMsg(..))
import Router
import Views.Home as Home
import Views.NewRoom


view : Spec problemType guessType -> Model problemType guessType -> Html (Msg problemType guessType)
view spec model =
    let
        content =
            case model.route of
                Router.Game roomId playerId maybeRoom ->
                    maybeRoom
                        |> Maybe.map (Html.map Guess << spec.view playerId)
                        |> Maybe.withDefault (div [] [])

                Router.Home ->
                    Home.view

                Router.NewRoomRoute newRoomModel ->
                    Html.map NewRoomMsgContainer (Views.NewRoom.view newRoomModel)

                _ ->
                    div [] []
    in
        div [ class "container" ]
            [ content
            ]
