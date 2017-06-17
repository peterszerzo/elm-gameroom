module Views.NewRoom exposing (..)

import Html exposing (Html, div, text, button, form, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Attributes exposing (class, style, type_, value, id, for, href, placeholder, disabled)
import Html.Events exposing (onClick, onInput, onSubmit)
import Models.NewRoom as NewRoom
import Messages.NewRoom exposing (NewRoomMsg(..))
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
        [ h2 [ localClass [ Title ] ] [ text "Game on!" ]
        , p [] [ text "But first, some forms.. In order to play with your friends, use this form to create your very own room. You’ll then be able to share links unique to each player, control when you feel ready, and be on your way!" ]
        , form
            [ onSubmit CreateRequest
            ]
            [ label [ for "roomid" ]
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
            , button
                [ localClassList [ ( Button, True ), ( FormButton, True ), ( ButtonDisabled, not canSubmit ) ]
                , type_ "submit"
                , disabled (not canSubmit)
                ]
                [ text "Create room" ]
            ]
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
