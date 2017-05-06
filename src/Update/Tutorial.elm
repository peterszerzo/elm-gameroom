module Update.Tutorial exposing (..)

import Random
import Messages
import Messages.Tutorial exposing (Msg(..))
import Models.Tutorial exposing (Tutorial)
import Gameroom.Spec exposing (Spec)


update :
    Spec problem guess
    -> Msg problem guess
    -> Tutorial problem guess
    -> ( Tutorial problem guess, Cmd (Messages.Msg problem guess) )
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
                , animationTicksSinceNewRound = 0
              }
            , Cmd.none
            )

        Guess guess ->
            ( { model | guess = Just guess }, Cmd.none )

        AnimationTick _ ->
            ( { model | animationTicksSinceNewRound = model.animationTicksSinceNewRound + 1 }, Cmd.none )
