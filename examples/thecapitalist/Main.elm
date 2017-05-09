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
    { copy =
        { name = "The Capitalist"
        , subheading = "Person who knows the capital of a lot of countries, that is.."
        , instructions = "Find the capital of the country!"
        }
    , view =
        (\windowSize ticksSinceNewRound playerId players problem ->
            div
                [ style
                    [ ( "width", "100%" )
                    , ( "height", "100%" )
                    , ( "display", "flex" )
                    , ( "align-items", "center" )
                    , ( "vertical-align", "middle" )
                    ]
                ]
                [ div
                    [ style
                        [ ( "margin", "0" )
                        , ( "width", "auto" )
                        , ( "max-width", "400px" )
                        , ( "text-align", "center" )
                        ]
                    ]
                    [ h1 [] [ text problem.question ]
                    , ul
                        [ style
                            [ ( "list-style", "none" )
                            , ( "padding-left", "0" )
                            ]
                        ]
                        (List.indexedMap
                            (\index answer ->
                                li
                                    [ onClick index
                                    , style
                                        [ ( "margin", "20px" )
                                        , ( "border", "1px solid currentColor" )
                                        , ( "padding", "6px 12px" )
                                        ]
                                    ]
                                    [ text answer ]
                            )
                            problem.answers
                        )
                    ]
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == problem.correct))
    , problemGenerator =
        generatorFromList
            { question = "🇱🇻 Latvia"
            , answers = [ "Tallin", "Riga", "Vilnius", "Moscow" ]
            , correct = 1
            }
            [ { question = "🇭🇺 Hungary"
              , answers = [ "Budapest", "Pécs", "Mosonmagyaróvár", "Garmisch-Partenkirchen" ]
              , correct = 0
              }
            , { question = "🇧🇳 Brunei"
              , answers = [ "Munich", "Copenhagen", "Jakarta", "Bandar Seri Begawan" ]
              , correct = 3
              }
            , { question = "🇸🇮 Slovenia"
              , answers = [ "Munich", "Ljubljana", "Jakarta", "Bandar Seri Begawan" ]
              , correct = 1
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
    Gameroom.programAt "thecapitalist" spec ports
