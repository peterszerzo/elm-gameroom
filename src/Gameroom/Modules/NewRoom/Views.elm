module Gameroom.Modules.NewRoom.Views exposing (..)

import Html exposing (Html, div, text, button, h1, label, input, fieldset, span)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Html.Events exposing (onClick, onInput)
import Gameroom.Modules.NewRoom.Models exposing (Model)
import Gameroom.Messages exposing (Msg(..), NewRoomMsg(..))
import Gameroom.Views.Styles as Styles


view : Model -> Html NewRoomMsg
view model =
    let
        canSubmit =
            (String.length model.roomId > 0)
                && (model.playerIds |> List.map (\playerId -> String.length playerId > 0) |> List.all identity)
    in
        div [ style Styles.centered ]
            [ label [ for "roomid", style Styles.label ]
                [ text "Room Id"
                , input [ id "roomid", type_ "text", onInput ChangeRoomId, value model.roomId, style Styles.input ] []
                ]
            , div []
                (List.indexedMap
                    (\index playerId ->
                        let
                            fieldId =
                                "playerid-" ++ (toString index)
                        in
                            label [ for fieldId, style Styles.label ]
                                [ text ("Player " ++ (toString (index + 1)))
                                , input [ id fieldId, style Styles.input, type_ "text", onInput (ChangePlayerId index), value (List.drop index model.playerIds |> List.head |> Maybe.withDefault "") ] []
                                , span [ onClick (RemovePlayer index) ] [ text "Remove" ]
                                ]
                    )
                    model.playerIds
                )
            , button [ onClick AddPlayer ] [ text "Add player" ]
            , (if canSubmit then
                input [ type_ "submit", onClick Submit ] []
               else
                div [] []
              )
            ]
