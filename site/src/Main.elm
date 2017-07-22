module Main exposing (..)

import Time
import AnimationFrame
import Html exposing (Html, div, h1, h2, p, a, text, program, node, footer, main_, header)
import Html.Attributes exposing (class, href)
import Views.Logo
import Styles exposing (cssText, CssClasses(..), localClass)


main : Program Never Model Msg
main =
    program
        { view = view
        , update = update
        , init = init
        , subscriptions = subscriptions
        }


games : List String
games =
    [ "lettero"
    , "counterclockwooze"
    , "spacecraterball"
    , "the-capitalist"
    , "fast-and-moebius"
    ]


type alias Model =
    { time : Time.Time
    }


type Msg
    = Tick Time.Time


init : ( Model, Cmd Msg )
init =
    ( Model 0, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    AnimationFrame.times Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            ( { model | time = time }, Cmd.none )


view : Model -> Html msg
view model =
    div [ localClass [ Root ] ] <|
        [ node "style" [] [ cssText |> text ]
        , header []
            [ Views.Logo.animatedView 1 model.time
            , h1 [] [ text "elm-gameroom" ]
            , p [] [ text "framework for reliably custom multiplayer games" ]
            ]
        , main_ []
            [ p [] [ text "hey, feel like playing? here is a collection of multiplayer games written in a few hundred lines each in the comfortable, trusted hands of ElmLang:" ]
            , div [] <|
                List.map
                    (\game ->
                        a
                            [ localClass [ Link ]
                            , href ("/" ++ game)
                            ]
                            [ text game ]
                    )
                    games
            ]
        , footer []
            [ p []
                [ text "find the project on  "
                , a
                    [ localClass [ SimpleLink ]
                    , href "http://package.elm-lang.org/packages/peterszerzo/elm-gameroom/latest"
                    ]
                    [ text "GitHub" ]
                , text ". feel free to open a new pull request if you have game ideas"
                ]
            ]
        ]
