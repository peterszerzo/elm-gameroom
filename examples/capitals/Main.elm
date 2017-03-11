port module Main exposing (..)

import Html exposing (Html, div, text, span, h1, ul, li)
import Html.Attributes exposing (class, style, attribute)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (program, Model, Msg, Ports)
import Gameroom.Spec exposing (Spec)
import Gameroom.Utilities exposing (generatorFromList)


-- Types


type alias Problem =
    { question : String
    , answers : List String
    , correct : Int
    }


type alias Guess =
    Int



-- Spec


spec : Spec Problem Guess
spec =
    { view =
        (\playerId players problem ->
            div
                [ class "spinning-shapes-container"
                , style
                    [ ( "position", "absolute" )
                    , ( "width", "80vmin" )
                    , ( "height", "80vmin" )
                    , ( "top", "50%" )
                    , ( "left", "50%" )
                    , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0)" )
                    ]
                ]
                [ h1 [] [ text problem.question ]
                , ul [] (List.indexedMap (\index answer -> li [ onClick index ] [ text answer ]) problem.answers)
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == problem.correct))
    , problemGenerator =
        generatorFromList
            { question = "What's the capital of Latvia?"
            , answers = [ "Tallin", "Riga", "Vilnius", "Moscow" ]
            , correct = 2
            }
            [ { question = "What's the capital of Hungary?"
              , answers = [ "Budapest", "Pécs", "Mosonmagyaróvár", "Garmisch-Partenkirchen" ]
              , correct = 0
              }
            ]
    , guessEncoder = JE.int
    , guessDecoder = JD.int
    , problemEncoder =
        (\pb ->
            JE.object
                [ ( "question", JE.string pb.question )
                , ( "answers", List.map JE.string pb.answers |> JE.list )
                , ( "correct", JE.int pb.correct )
                ]
        )
    , problemDecoder =
        JD.map3 Problem
            (JD.field "question" JD.string)
            (JD.field "answers" (JD.list JD.string))
            (JD.field "correct" JD.int)
    }



-- Config


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }



-- Program


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    Gameroom.program spec ports
