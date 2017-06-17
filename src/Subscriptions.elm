module Subscriptions exposing (..)

import Window
import Json.Decode as JD
import Messages
import Messages.Tutorial
import Router as Router
import Models.Ports as Ports
import Gameroom.Spec as Spec
import Models exposing (Model)
import Models.IncomingMessage as InMsg
import AnimationFrame


subscriptions :
    Spec.Spec problem guess
    -> Ports.Ports (Messages.Msg problem guess)
    -> Model problem guess
    -> Sub (Messages.Msg problem guess)
subscriptions spec ports model =
    Sub.batch
        [ ports.incoming
            (\val ->
                val
                    |> JD.decodeValue (InMsg.decoder spec.problemDecoder spec.guessDecoder)
                    |> Result.map Messages.IncomingSubscription
                    |> Result.withDefault Messages.NoOp
            )
        , case model.route of
            Router.Game _ ->
                Sub.batch
                    [ AnimationFrame.times (Messages.GameMsg << Messages.Tick)
                    , Window.resizes Messages.Resize
                    ]

            Router.Tutorial _ ->
                Sub.batch
                    [ AnimationFrame.times (Messages.TutorialMsg << Messages.Tutorial.Tick)
                    , Window.resizes Messages.Resize
                    ]

            _ ->
                Sub.none
        ]
