module Subscriptions exposing (..)

import Time
import Json.Decode as JD
import Messages
import Messages.Tutorial
import Constants
import Router as Router
import Models.Ports as Ports
import Gameroom.Spec as Spec
import Models exposing (Model)
import Models.IncomingMessage as InMsg
import AnimationFrame


subscriptions : Spec.Spec problem guess -> Ports.Ports (Messages.Msg problem guess) -> Model problem guess -> Sub (Messages.Msg problem guess)
subscriptions spec ports model =
    Sub.batch
        [ ports.incoming
            (\val ->
                val
                    |> JD.decodeString (InMsg.decoder spec.problemDecoder spec.guessDecoder)
                    |> Result.map Messages.IncomingSubscription
                    |> Result.withDefault Messages.NoOp
            )
        , case model.route of
            Router.Game _ ->
                -- Debugging mode only
                Sub.batch
                    [ if Constants.debugMode then
                        Time.every (1000 * Time.millisecond) (Messages.GameMsg << Messages.Tick)
                      else
                        Time.every (100 * Time.millisecond) (Messages.GameMsg << Messages.Tick)
                    , AnimationFrame.times (Messages.GameMsg << Messages.AnimationTick)
                    ]

            Router.Tutorial _ ->
                Sub.batch [ AnimationFrame.times (Messages.TutorialMsg << Messages.Tutorial.AnimationTick) ]

            _ ->
                Sub.none
        ]
