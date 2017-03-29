module Views.NewRoom exposing (..)

import Html exposing (Html, div, text, button, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Attributes exposing (class, style, type_, value, id, for, href)
import Html.Events exposing (onClick, onInput)
import Models.NewRoom as NewRoom
import Messages exposing (NewRoomMsg(..))
import Views.Styles as Styles


viewForm : NewRoom.NewRoom -> Html NewRoomMsg
viewForm model =
    let
        canSubmit =
            (String.length model.roomId > 0)
                && (model.playerIds |> List.map (\playerId -> String.length playerId > 0) |> List.all identity)
    in
        div [ style Styles.centered ]
            [ label [ for "roomid", style Styles.label ]
                [ text "Room Id"
                , input
                    [ id "roomid"
                    , type_ "text"
                    , onInput ChangeRoomId
                    , value model.roomId
                    , style Styles.input
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
                            label [ for fieldId, style Styles.label ]
                                ([ text ("Player " ++ (toString (index + 1)))
                                 , input
                                    [ id fieldId
                                    , style Styles.input
                                    , type_ "text"
                                    , onInput (ChangePlayerId index)
                                    , value (List.drop index model.playerIds |> List.head |> Maybe.withDefault "")
                                    ]
                                    []
                                 ]
                                    ++ (if List.length model.playerIds > 2 then
                                            [ span
                                                [ onClick (RemovePlayer index)
                                                ]
                                                [ text "Remove" ]
                                            ]
                                        else
                                            []
                                       )
                                )
                    )
                    model.playerIds
                )
            , button
                [ style
                    (Styles.link
                        ++ [ ( "margin", "20px 0 0" )
                           , ( "width", "100%" )
                           ]
                    )
                , onClick AddPlayer
                ]
                [ text "Add player" ]
            , (if canSubmit then
                input
                    [ style
                        (Styles.link
                            ++ [ ( "margin", "20px 0 0" )
                               , ( "width", "100%" )
                               ]
                        )
                    , type_ "submit"
                    , onClick CreateRequest
                    ]
                    []
               else
                div [] []
              )
            ]


viewSuccess : NewRoom.NewRoom -> Html NewRoomMsg
viewSuccess model =
    div [ style Styles.centered ]
        [ h2
            [ style Styles.subheroType
            ]
            [ text "Your room is ready" ]
        , p
            [ style
                Styles.bodyType
            ]
            [ text "Navigate to these links and share them with your opponents:" ]
        , ul [ style [ ( "list-style", "none" ), ( "margin", "20px 0 0" ), ( "padding", "0" ) ] ]
            (model.playerIds
                |> List.map
                    (\id ->
                        li
                            [ style
                                [ ( "display", "inline-block" )
                                ]
                            ]
                            [ a
                                [ style Styles.link
                                , href ("/rooms/" ++ model.roomId ++ "/" ++ id)
                                ]
                                [ text id ]
                            ]
                    )
            )
        ]


view : NewRoom.NewRoom -> Html NewRoomMsg
view model =
    case model.status of
        NewRoom.Editing ->
            viewForm model

        NewRoom.Success ->
            viewSuccess model

        _ ->
            div [] [ text "View not available." ]
