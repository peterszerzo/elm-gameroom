module Update.Tutorial exposing (..)

import Random
import Messages exposing (Msg)
import Models.RoundTime as RoundTime
import Messages.Tutorial exposing (TutorialMsg(..))
import Models.Tutorial exposing (Tutorial)
import Gameroom.Spec exposing (Spec)


update :
    Spec problem guess
    -> TutorialMsg problem guess
    -> Tutorial problem guess
    -> ( Tutorial problem guess, Cmd (Msg problem guess) )
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
