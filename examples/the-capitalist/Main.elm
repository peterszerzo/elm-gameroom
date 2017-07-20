port module Main exposing (..)

import Random
import Html exposing (Html, div, text, span, h1, ul, li)
import Html.Attributes exposing (class, style, attribute)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Json.Decode as Decode
import Gameroom exposing (..)
import Gameroom.Context exposing (Context)


-- Main


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    gameWith
        [ basePath "/the-capitalist"
        , unicodeIcon "💰"
        , name "The Capitalist"
        , subheading "Oh, not that kind, though, more like a person who knows the capital of a lot of countries.."
        , instructions "Find the capital of the country!"
        , clearWinner 100
        , responsiblePorts { outgoing = outgoing, incoming = incoming }
        ]
        spec



-- Types, encoders and decoders


type alias Problem =
    { question : String
    , answers : List String
    , correct : Int
    }


problemEncoder : Problem -> Encode.Value
problemEncoder problem =
    Encode.object
        [ ( "question", Encode.string problem.question )
        , ( "answers"
          , List.map Encode.string problem.answers
                |> Encode.list
          )
        , ( "correct", Encode.int problem.correct )
        ]


problemDecoder : Decode.Decoder Problem
problemDecoder =
    Decode.map3 Problem
        (Decode.field "question" Decode.string)
        (Decode.field "answers" (Decode.list Decode.string))
        (Decode.field "correct" Decode.int)


type alias Guess =
    Int


guessEncoder : Guess -> Encode.Value
guessEncoder =
    Encode.int


guessDecoder : Decode.Decoder Guess
guessDecoder =
    Decode.int



-- Game spec


spec : Spec Problem Guess
spec =
    { view = view
    , evaluate = evaluate
    , problemGenerator = problemGenerator
    , guessEncoder = guessEncoder
    , guessDecoder = guessDecoder
    , problemEncoder = problemEncoder
    , problemDecoder = problemDecoder
    }


view : Context Guess -> Problem -> Html Guess
view context problem =
    -- not used, only here to show a more concise version of the game view
    div []
        [ div []
            [ h1 [] [ text problem.question ]
            , ul []
                (List.indexedMap
                    (\index answer ->
                        -- events map to raw guesses (in this case, an Int)
                        li [ onClick index ] [ text answer ]
                    )
                    problem.answers
                )
            ]
        ]


styledView : Context Guess -> Problem -> Html Guess
styledView context problem =
    div [ style containerStyle ]
        [ div [ style contentStyle ]
            [ h1 [] [ text problem.question ]
            , ul
                [ style listStyle
                ]
                (List.indexedMap
                    (\index answer ->
                        let
                            isGuessedBySelf =
                                context.ownGuess == (Just index)

                            isMarkedCorrect =
                                (index == problem.correct) && (isGuessedBySelf || context.isRoundOver)
                        in
                            li
                                [ onClick index
                                , style <|
                                    listItemBaseStyle isGuessedBySelf isMarkedCorrect
                                ]
                                [ text answer ]
                    )
                    problem.answers
                )
            ]
        ]


evaluate : Problem -> Guess -> Float
evaluate problem guess =
    -- a correct guess maps to a higher evaluation
    if (guess == problem.correct) then
        100
    else
        0


problemGenerator : Random.Generator Problem
problemGenerator =
    generatorFromList
        { question = "🇱🇻 Latvia"
        , answers = [ "Tallin", "Riga", "Vilnius", "Moscow" ]
        , correct = 1
        }
        -- a list of problems identical to the record above
        problems



-- Ports


port outgoing : Encode.Value -> Cmd msg


port incoming : (Encode.Value -> msg) -> Sub msg



-- Problem DB


problems : List Problem
problems =
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
    , { question = "🇫🇷 France"
      , answers = [ "Bordeaux", "Paris", "Paris, NY" ]
      , correct = 1
      }
    , { question = "🇩🇪 Germany"
      , answers = [ "Bordeaux", "Berlin, NH", "Berlin", "Stuttgart" ]
      , correct = 2
      }
    , { question = "🇩🇰 Denmark"
      , answers = [ "Ansterdam", "Aarhus", "Copenhagen", "Christiania" ]
      , correct = 2
      }
    ]



-- Styles


containerStyle : List ( String, String )
containerStyle =
    [ ( "width", "100%" )
    , ( "height", "100%" )
    , ( "display", "flex" )
    , ( "align-items", "center" )
    , ( "justify-content", "center" )
    ]


contentStyle : List ( String, String )
contentStyle =
    [ ( "margin", "0" )
    , ( "width", "auto" )
    , ( "max-width", "440px" )
    , ( "text-align", "center" )
    ]


listStyle : List ( String, String )
listStyle =
    [ ( "list-style", "none" )
    , ( "padding-left", "0" )
    ]


listItemBaseStyle : Bool -> Bool -> List ( String, String )
listItemBaseStyle isGuessedBySelf isMarkedCorrect =
    [ ( "margin", "12px" )
    , ( "display", "inline-block" )
    , ( "border-width", "1px" )
    , ( "border-style", "solid" )
    , ( "cursor", "pointer" )
    , ( "padding", "8px 16px" )
    , ( "border-radius", "6px" )
    ]
        ++ [ ( "border-color"
             , if isGuessedBySelf then
                "#333333"
               else
                "transparent"
             )
           , ( "background-color"
             , if isMarkedCorrect then
                "#333333"
               else
                "transparent"
             )
           , ( "color"
             , if isMarkedCorrect then
                "#FFFFFF"
               else
                "#333333"
             )
           ]
