module Views.NewRoom exposing (..)

import Html exposing (Html, div, text, button, h1, label, input, fieldset)
import Html.Attributes exposing (class, style, type_, value, id, for)
import Html.Events exposing (onClick, onInput)
import Models.NewRoom as NewRoom
import Messages exposing (Msg(..), NewRoomMsg(..))
import Views.Styles as Styles


view : NewRoom.NewRoom -> Html NewRoomMsg
view model =
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
                            ]
                )
                model.playerIds
            )
        , button [ onClick AddPlayer ] [ text "Add player" ]
        ]
