module Views.NewRoom exposing (..)

import Html exposing (Html, div, text, button, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Attributes exposing (class, style, type_, value, id, for, href)
import Html.Events exposing (onClick, onInput)
import Models.NewRoom as NewRoom
import Messages exposing (NewRoomMsg(..))
import Views.NewRoom.Styles exposing (CssClasses(..), localClass)


viewForm : NewRoom.NewRoom -> List (Html NewRoomMsg)
viewForm model =
    let
        canSubmit =
            (String.length model.roomId > 0)
                && (model.playerIds |> List.map (\playerId -> String.length playerId > 0) |> List.all identity)
    in
        [ h2 [] [ text "Create your room" ]
        , p [] [ text "Casual is key - so please excuse our insistence to make your names URL-friendly as you type :)." ]
        , label [ for "roomid" ]
            [ text "Room Id"
            , input
                [ id "roomid"
                , type_ "text"
                , onInput ChangeRoomId
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
        ]


viewSuccess : NewRoom.NewRoom -> List (Html NewRoomMsg)
viewSuccess model =
    [ h2 [] [ text "Your room is ready" ]
    , p [] [ text "Navigate to these links and share them with your opponents:" ]
    , ul
        [ style
            [ ( "list-style", "none" )
            , ( "margin", "20px 0 0" )
            , ( "padding", "0" )
            ]
        ]
        (model.playerIds
            |> List.map
                (\id ->
                    li
                        [ style
                            [ ( "display", "inline-block" )
                            ]
                        ]
                        [ a
                            [ localClass [ Button ]
                            , href ("/rooms/" ++ model.roomId ++ "/" ++ id)
                            ]
                            [ text id ]
                        ]
                )
        )
    ]


view : NewRoom.NewRoom -> Html NewRoomMsg
view model =
    div [ localClass [ Root ] ]
        (case model.status of
            NewRoom.Editing ->
                viewForm model

            NewRoom.Success ->
                viewSuccess model

            _ ->
                [ text "View not available." ]
        )
