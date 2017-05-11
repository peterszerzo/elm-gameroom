module Views.NewRoom exposing (..)

import Html exposing (Html, div, text, button, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Attributes exposing (class, style, type_, value, id, for, href, placeholder)
import Html.Events exposing (onClick, onInput)
import Models.NewRoom as NewRoom
import Messages exposing (NewRoomMsg(..))
import Views.NewRoom.Styles exposing (CssClasses(..), localClass, localClassList)
import Views.Loader
import Views.Notification


viewForm : NewRoom.NewRoom -> List (Html NewRoomMsg)
viewForm model =
    let
        canSubmit =
            (String.length model.roomId > 0)
                && (model.playerIds |> List.map (\playerId -> String.length playerId > 0) |> List.all identity)
    in
        [ h2 [] [ text "Create your room" ]
        , p [] [ text "" ]
        , label [ for "roomid" ]
            [ text "Room Id"
            , input
                [ id "roomid"
                , type_ "text"
                , onInput ChangeRoomId
                , placeholder "e.g. theroom"
                , value model.roomId
                ]
                []
            ]
        , div []
            (List.indexedMap
                (\index playerId ->
                    let
                        fieldId =
                            "playerid-" ++ (toString index)
                    in
                        label [ for fieldId ]
                            ([ text ("Player " ++ (toString (index + 1)))
                             , input
                                [ id fieldId
                                , type_ "text"
                                , onInput (ChangePlayerId index)
                                , placeholder
                                    (if rem index 2 == 0 then
                                        "e.g. alfred"
                                     else
                                        "e.g. samantha"
                                    )
                                , value (List.drop index model.playerIds |> List.head |> Maybe.withDefault "")
                                ]
                                []
                             ]
                                ++ (if List.length model.playerIds > 2 then
                                        [ button
                                            [ onClick (RemovePlayer index)
                                            ]
                                            [ text "✕" ]
                                        ]
                                    else
                                        []
                                   )
                            )
                )
                model.playerIds
            )
        , button
            [ localClass [ Button, FormButton ]
            , onClick AddPlayer
            ]
            [ text "Add player" ]
        , (if canSubmit then
            button
                [ localClass [ Button, FormButton ]
                , type_ "submit"
                , onClick CreateRequest
                ]
                [ text "Create room" ]
           else
            div [] []
          )
        , Views.Notification.view
            (if not model.entriesUrlized || model.isUrlizedNotificationDismissed then
                Nothing
             else
                Just "We took the liberty to make your names casual and URL-friendly for your convenience :)."
            )
            (Just DismissUrlizeNotification)
        ]


view : NewRoom.NewRoom -> Html NewRoomMsg
view model =
    div [ localClass [ Root ] ]
        (case model.status of
            NewRoom.Editing ->
                viewForm model

            NewRoom.Pending ->
                [ Views.Loader.view ]

            NewRoom.Error ->
                [ h2 [] [ text "There was an error creating your room :/" ]
                , p [] [ text "Please reload the page and try again." ]
                , a [ href "new", localClass [ Button ] ] [ text "Reload" ]
                ]
        )
