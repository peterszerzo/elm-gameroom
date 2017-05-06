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
        , onClick (Messages.Tutorial.ClickAnywhere)
        ]
        [ Views.Notification.view
            (model.problem
                |> Maybe.map
                    (\problem ->
                        case model.guess of
                            Nothing ->
                                "Take a guess"

                            Just guess ->
                                if spec.isGuessCorrect problem guess then
                                    "Nice job! Click for a new problem."
                                else
                                    "Incorrect.. click for a new problem."
                    )
                |> Maybe.withDefault "Hey, let's practice. Click anywhere to get your first problem!"
                |> Just
            )
        , model.problem
            |> Maybe.map (spec.view "testplayer" Dict.empty model.animationTicksSinceNewRound)
            |> Maybe.map (map Messages.Tutorial.Guess)
            |> Maybe.withDefault (div [] [])
        ]
