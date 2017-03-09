port module Main exposing (..)

import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (program, Model, Msg)
import Gameroom.Ports exposing (Ports)
import Gameroom.Spec exposing (Spec)
import Gameroom.Utilities exposing (generatorFromList)


-- Types


type alias ProblemType =
    String


type alias GuessType =
    Int



-- Spec


spec : Spec ProblemType GuessType
spec =
    { view =
        (\playerId players problem ->
            div
                [ style
                    [ ( "position", "absolute" )
                    , ( "max-width", "800px" )
                    , ( "max-height", "800px" )
                    , ( "top", "50%" )
                    , ( "left", "50%" )
                    , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0)" )
                    ]
                ]
                [ div [ class "word " ]
                    (problem
                        |> String.toList
                        |> List.indexedMap
                            (\index c ->
                                span
                                    [ style
                                        [ ( "font-size", "2rem" )
                                        ]
                                    , onClick index
                                    ]
                                    [ text (String.fromChar c) ]
                            )
                    )
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , problemGenerator =
        generatorFromList "perrywinkle"
            [ "gingerberry"
            , "apples"
            , "vineyard"
            , "is"
            , "tablespoon"
            , "cutlery"
            , "laborer"
            , "projector"
            ]
    , guessEncoder = JE.int
    , guessDecoder = JD.int
    , problemEncoder = JE.string
    , problemDecoder = JD.string
    }



-- Config


port unsubscribeFromRoom : String -> Cmd msg


port subscribeToRoom : String -> Cmd msg


port updateRoom : String -> Cmd msg


port roomUpdated : (String -> msg) -> Sub msg


port createRoom : String -> Cmd msg


port roomCreated : (String -> msg) -> Sub msg


port updatePlayer : String -> Cmd msg


port playerUpdated : (String -> msg) -> Sub msg


config : Ports (Msg ProblemType GuessType)
config =
    { unsubscribeFromRoom = unsubscribeFromRoom
    , subscribeToRoom = subscribeToRoom
    , updateRoom = updateRoom
    , roomUpdated = roomUpdated
    , createRoom = createRoom
    , roomCreated = roomCreated
    , updatePlayer = updatePlayer
    , playerUpdated = playerUpdated
    }


main : Program Never (Model ProblemType GuessType) (Msg ProblemType GuessType)
main =
    Gameroom.program spec config
