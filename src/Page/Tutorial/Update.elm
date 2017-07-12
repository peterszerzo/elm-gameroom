module Page.Tutorial.Update exposing (..)

import Random
import Messages
import Data.RoundTime as RoundTime
import Page.Tutorial.Messages exposing (Msg(..))
import Page.Tutorial.Models exposing (Model)
import Data.Spec as Spec


update :
    Spec.DetailedSpec problem guess
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Messages.Msg problem guess) )
update spec msg model =
    case msg of
        RequestNewProblem ->
            ( model
            , Random.generate (Messages.TutorialMsg << ReceiveProblem) spec.problemGenerator
            )

        ReceiveProblem problem ->
            ( { model
                | problem = Just problem
                , guess = Nothing
                , time = RoundTime.init
              }
            , Cmd.none
            )

        Guess guess ->
            ( { model | guess = Just guess }, Cmd.none )

        Tick time ->
            ( { model | time = RoundTime.update time model.time }, Cmd.none )
