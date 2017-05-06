module Views.Tutorial exposing (..)

import Dict
import Html exposing (Html, map, div, text, button, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Events exposing (onClick)
import Gameroom.Spec exposing (Spec)
import Models.Tutorial
import Messages.Tutorial
import Views.Tutorial.Styles exposing (CssClasses(..), localClass)
import Views.Notification


view :
    Spec problem guess
    -> Models.Tutorial.Tutorial problem guess
    -> Html (Messages.Tutorial.Msg problem guess)
view spec model =
    div
        [ localClass [ Root ]
        ]
        [ Views.Notification.view
            (model.problem
                |> Maybe.map
                    (\problem ->
                        case model.guess of
                            Nothing ->
                                "Take a guess. Take your time now, just bear in mind it'll be against the clock in the real game!"

                            Just guess ->
                                if spec.isGuessCorrect problem guess then
                                    "Nice job - click the button for more problems, or the top left to exit."
                                else
                                    "Not quite, not quite.. Care to try again?"
                    )
                |> Maybe.withDefault "Hey, let's practice. Click the button to get a game problem you can solve."
                |> Just
            )
        , div [ localClass [ Button ], onClick Messages.Tutorial.RequestNewProblem ] [ text "▶" ]
        , model.problem
            |> Maybe.map (spec.view "testplayer" Dict.empty model.animationTicksSinceNewRound)
            |> Maybe.map (map Messages.Tutorial.Guess)
            |> Maybe.withDefault (div [] [])
        ]
