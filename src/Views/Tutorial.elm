module Views.Tutorial exposing (..)

import Window
import Html exposing (Html, map, div, text, button, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Events exposing (onClick)
import Models.RoundTime as RoundTime
import Models.Spec as Spec
import Models.Tutorial
import Messages.Tutorial
import Views.Tutorial.Styles exposing (CssClasses(..), localClass)
import Views.Notification


view :
    Spec.DetailedSpec problem guess
    -> Window.Size
    -> Models.Tutorial.Tutorial problem guess
    -> Html (Messages.Tutorial.TutorialMsg problem guess)
view spec windowSize model =
    let
        roundTime =
            RoundTime.timeSinceNewRound model.time
    in
        div
            [ localClass [ Root ]
            ]
            [ Views.Notification.view
                (model.problem
                    |> Maybe.map
                        (\problem ->
                            case model.guess of
                                Nothing ->
                                    spec.instructions

                                Just guess ->
                                    "This one will score you a " ++ (spec.evaluate problem guess roundTime |> toString) ++ ". Can you do better?"
                        )
                    |> Maybe.withDefault "Hey, let's practice. Click the button to get a game problem you can solve."
                    |> Just
                )
                Nothing
            , div [ localClass [ Button ], onClick Messages.Tutorial.RequestNewProblem ] [ text "▶" ]
            , model.problem
                |> Maybe.map
                    (spec.view
                        { windowSize = windowSize
                        , roundTime = roundTime
                        , ownGuess = model.guess
                        , opponentGuesses = []
                        , isRoundOver = False
                        }
                    )
                |> Maybe.map (map Messages.Tutorial.Guess)
                |> Maybe.withDefault (div [] [])
            ]
