module Page.Tutorial.Update exposing (..)

import Data.RoundTime as RoundTime
import Page.Tutorial.Messages exposing (Msg(..))
import Page.Tutorial.Models exposing (Model)
import Data.Spec as Spec


update :
    Spec.DetailedSpec problem guess
    -> Msg problem guess
    -> Model problem guess
       -- Returns the new model and a boolean value; if it's true, the higher-level update function should generate a new game round.
    -> ( Model problem guess, Bool )
update spec msg model =
    case msg of
        RequestNewProblem ->
            ( model, True )

        ReceiveProblem problem ->
            ( { model
                | problem = Just problem
                , guess = Nothing
                , time = RoundTime.init
              }
            , False
            )

        Guess guess ->
            ( { model | guess = Just guess }, False )

        Tick time ->
            ( { model | time = RoundTime.update time model.time }, False )
