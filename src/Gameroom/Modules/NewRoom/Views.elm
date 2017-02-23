module Gameroom.Modules.NewRoom.Views exposing (..)

import Html exposing (Html, div, text, button, h1, label, input, fieldset, span, ul, li, a)
import Html.Attributes exposing (class, style, type_, value, id, for, href)
import Html.Events exposing (onClick, onInput)
import Gameroom.Modules.NewRoom.Models exposing (Model, Status(..))
import Gameroom.Modules.NewRoom.Messages exposing (Msg(..))
import Gameroom.Views.Styles as Styles


viewForm : Model -> Html Msg
viewForm model =
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
                                ([ text ("Player " ++ (toString (index + 1)))
                                 , input [ id fieldId, style Styles.input, type_ "text", onInput (ChangePlayerId index), value (List.drop index model.playerIds |> List.head |> Maybe.withDefault "") ] []
                                 ]
                                    ++ (if List.length model.playerIds > 2 then
                                            [ span [ onClick (RemovePlayer index) ] [ text "Remove" ] ]
                                        else
                                            []
                                       )
                                )
                    )
                    model.playerIds
                )
            , button [ onClick AddPlayer ] [ text "Add player" ]
            , (if canSubmit then
                input [ type_ "submit", onClick CreateRequest ] []
               else
                div [] []
              )
            ]


viewSuccess : Model -> Html Msg
viewSuccess model =
    div [ style Styles.centered ]
        [ ul []
            (model.playerIds
                |> List.map
                    (\id ->
                        li []
                            [ a [ href ("/rooms/" ++ model.roomId ++ "/" ++ id) ] [ text id ]
                            ]
                    )
            )
        ]


view : Model -> Html Msg
view model =
    case model.status of
        Editing ->
            viewForm model

        Success ->
            viewSuccess model

        _ ->
            div [] [ text "View not available." ]
