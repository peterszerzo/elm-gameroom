module Subscriptions exposing (..)

import Window
import Time
import Json.Decode as JD
import Messages
import Data.Route as Route
import Models exposing (Model)
import Page.Tutorial.Messages
import Page.Game.Messages
import Data.Spec as Spec
import Data.IncomingMessage as InMsg
import AnimationFrame


subscriptions :
    Spec.DetailedSpec problem guess
    -> Model problem guess
    -> Sub (Messages.Msg problem guess)
subscriptions spec model =
    Sub.batch
        [ (spec.ports
            |> Maybe.map .incoming
            |> Maybe.withDefault (always Sub.none)
          )
            (\val ->
                val
                    |> JD.decodeValue (InMsg.decoder spec.problemDecoder spec.guessDecoder)
                    |> Result.map Messages.IncomingMessage
                    |> Result.withDefault Messages.NoOp
            )
        , case model.route of
            Route.Game _ ->
                Sub.batch
                    [ -- This extra timer is necessary for when the game is tested in two different browser windows (animationframe doesn't fire when the tab is not active).
                      Time.every (100 * Time.millisecond) (Messages.GameMsg << Page.Game.Messages.Tick)
                    , AnimationFrame.times (Messages.GameMsg << Page.Game.Messages.Tick)
                    , Window.resizes Messages.Resize
                    ]

            Route.Tutorial _ ->
                Sub.batch
                    [ AnimationFrame.times (Messages.TutorialMsg << Page.Tutorial.Messages.Tick)
                    , Window.resizes Messages.Resize
                    ]

            _ ->
                Sub.none
        ]
