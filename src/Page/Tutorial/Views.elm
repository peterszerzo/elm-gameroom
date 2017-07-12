module Page.Tutorial.Views exposing (..)

import Window
import Html exposing (Html, map, div, text, button, h1, h2, label, input, fieldset, span, ul, li, a, p)
import Html.Events exposing (onClick)
import Data.RoundTime as RoundTime
import Data.Spec as Spec
import Page.Tutorial.Models exposing (Model)
import Page.Tutorial.Messages exposing (Msg(..))
import Page.Tutorial.Styles exposing (CssClasses(..), localClass)
import Views.Notification
import Utils
import Constants


view :
    Spec.DetailedSpec problem guess
    -> Window.Size
    -> Model problem guess
    -> Html (Msg problem guess)
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
                                    Constants.tutorialEvaluatedGuessCopy |> Utils.template (spec.evaluate problem guess |> toString)
                        )
                    |> Maybe.withDefault Constants.tutorialStartupCopy
                    |> Just
                )
                Nothing
            , div [ localClass [ Button ], onClick RequestNewProblem ] [ text "▶" ]
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
                |> Maybe.map (map Guess)
                |> Maybe.withDefault (div [] [])
            ]
