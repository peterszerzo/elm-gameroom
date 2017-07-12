module Subscriptions exposing (..)

import Window
import Time
import Json.Decode as JD
import Messages
import Page.Tutorial.Messages
import Page.Game.Messages
import Router as Router
import Models exposing (Model)
import Data.Ports as Ports
import Data.Spec as Spec
import Data.IncomingMessage as InMsg
import AnimationFrame


subscriptions :
    Spec.DetailedSpec problem guess
    -> Ports.Ports (Messages.Msg problem guess)
    -> Model problem guess
    -> Sub (Messages.Msg problem guess)
subscriptions spec ports model =
    Sub.batch
        [ ports.incoming
            (\val ->
                val
                    |> JD.decodeValue (InMsg.decoder spec.problemDecoder spec.guessDecoder)
                    |> Result.map Messages.IncomingMessage
                    |> Result.withDefault Messages.NoOp
            )
        , case model.route of
            Router.Game _ ->
                Sub.batch
                    [ Time.every (100 * Time.millisecond) (Messages.GameMsg << Page.Game.Messages.Tick)
                    , AnimationFrame.times (Messages.GameMsg << Page.Game.Messages.Tick)
                    , Window.resizes Messages.Resize
                    ]

            Router.Tutorial _ ->
                Sub.batch
                    [ AnimationFrame.times (Messages.TutorialMsg << Page.Tutorial.Messages.Tick)
                    , Window.resizes Messages.Resize
                    ]

            _ ->
                Sub.none
        ]
