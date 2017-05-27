port module Main exposing (..)

import Dict
import Html exposing (Html, div, text, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD
import Gameroom exposing (program, Model, Msg, Ports)
import Gameroom.Spec exposing (Spec)
import Gameroom.Utilities exposing (generatorFromList)


-- Types


type alias Problem =
    String


type alias Guess =
    Int



-- Spec


spec : Spec Problem Guess
spec =
    { copy =
        { icon = "✏️"
        , name = "Lettero"
        , subheading = "A mildly frustrating wordgame!"
        , instructions = "There is a word in there somewhere - tap its first letter!"
        }
    , view =
        (\windowSize ticksSinceNewRound status problem ->
            let
                isRoundOver =
                    status.roundResult /= Gameroom.Spec.Pending

                ownGuess =
                    Dict.get status.playerId status.guesses
            in
                div
                    [ style
                        [ ( "position", "absolute" )
                        , ( "width", "75vmin" )
                        , ( "height", "75vmin" )
                        , ( "top", "50%" )
                        , ( "left", "50%" )
                        , ( "transform", "scale(1.0, 1.0) translate3d(-50%, -50%, 0) rotate(" ++ ((ticksSinceNewRound |> toFloat) / 5 |> toString) ++ "deg)" )
                        ]
                    ]
                    (problem
                        |> String.toList
                        |> List.indexedMap
                            (\index character ->
                                let
                                    angle =
                                        (index |> toFloat)
                                            / (problem
                                                |> String.length
                                                |> toFloat
                                              )
                                            |> (*) (2 * pi)

                                    isGuessedBySelf =
                                        ownGuess == (Just index)

                                    isMarkedCorrect =
                                        (index == 0) && (isGuessedBySelf || isRoundOver)

                                    isGuessed =
                                        status.guesses
                                            |> Dict.toList
                                            |> List.filter (\( playerId, guess ) -> guess == index)
                                            |> List.head
                                            |> Maybe.map (\( playerId, guess ) -> guess == index)
                                            |> Maybe.withDefault False
                                in
                                    span
                                        [ style
                                            ([ ( "position", "absolute" )
                                             , ( "display", "block" )
                                             , ( "cursor", "pointer" )
                                             , ( "background-color", "rgba(255, 255, 255, 0.1)" )
                                             , ( "font-size", "calc(3vh + 3vw)" )
                                             , ( "width", "calc(4.5vh + 4.5vw)" )
                                             , ( "height", "calc(4.5vh + 4.5vw)" )
                                             , ( "padding-top", "calc(0.6vh + 0.6vw)" )
                                             , ( "line-height", "1" )
                                             , ( "border-radius", "50%" )
                                             , ( "text-align", "center" )
                                             , ( "border", "2px solid white" )
                                             , ( "top", ((1 - sin angle) * 50 |> toString) ++ "%" )
                                             , ( "left", ((1 - cos angle) * 50 |> toString) ++ "%" )
                                             , ( "transform", "translate3d(-50%, -50%, 0) rotate(" ++ ((angle * 180 / pi - 90) |> toString) ++ "deg)" )
                                             , ( "text-transform", "uppercase" )
                                             ]
                                                ++ (if isMarkedCorrect then
                                                        [ ( "border", "2px solid black" )
                                                        , ( "background-color", "black" )
                                                        , ( "color", "white" )
                                                        ]
                                                    else if (isGuessedBySelf || (isGuessed && isRoundOver)) then
                                                        [ ( "border", "2px solid black" )
                                                        ]
                                                    else
                                                        []
                                                   )
                                            )
                                        , onClick index
                                        ]
                                        [ text (String.fromChar character) ]
                            )
                    )
        )
    , isGuessCorrect = (\problem guess -> (guess == 0))
    , problemGenerator =
        generatorFromList "perrywinkle" <|
            [ "gingerberry", "apples", "vineyard", "is", "tablespoon", "cutlery", "laborer" ]
                ++ [ "grenade", "coaster", "mahogany", "burrito", "cilantro", "kettle" ]
                ++ [ "revenue", "stool", "ginger", "electricity", "purple", "backpack" ]
                ++ [ "phone", "bill", "family", "cucumber", "terrific", "towel", "tower" ]
                ++ [ "lightbulb", "leaf", "loaf", "parrot", "rack", "rope", "poor", "strap" ]
                ++ [ "faucet", "lipstick", "grapefruit", "pickle", "woodpecker" ]
    , guessEncoder = JE.int
    , guessDecoder = JD.int
    , problemEncoder = JE.string
    , problemDecoder = JD.string
    }



-- Config


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    Gameroom.programAt "lettero" spec ports
