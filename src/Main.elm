module Main exposing (..)

import Html exposing (Html, beginnerProgram, div, button, text, h1, p, span)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import GameRoom
import Models
import Dict
import Json.Encode as JE
import Json.Decode as JD


gameSpec : GameRoom.Spec String Int
gameSpec =
    { view =
        (\model ->
            case model.room of
                Just room ->
                    div []
                        [ h1 [] [ text ("welcome, " ++ model.playerId) ]
                        , p [] [ text ("your score: " ++ (toString (Dict.get model.playerId room.players |> Maybe.map (toString << .score) |> Maybe.withDefault "noscore"))) ]
                        , text ("round no. " ++ (toString room.round.no))
                        , div [ class "word " ]
                            (room.round.problem
                                |> String.toList
                                |> List.indexedMap (\index c -> span [ onClick index ] [ text (String.fromChar c) ])
                            )
                        ]

                Nothing ->
                    div []
                        [ h1 [] [ text ("welcome, " ++ model.playerId) ]
                        , p [] [ text "loading.." ]
                        ]
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , guessEncoder = (JE.int)
    , guessDecoder = (JD.int)
    , problemEncoder = (JE.string)
    , problemDecoder = (JD.string)
    }


main : Program Never (Models.Model String Int) (GameRoom.Msg Int)
main =
    GameRoom.program gameSpec
