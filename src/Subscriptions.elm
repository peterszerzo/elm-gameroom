module Subscriptions exposing (..)

import Time
import Json.Decode as JD
import Constants as Consts
import Messages.Main as Messages
import Messages.Game as GameMessages
import Router as Router
import Models.Ports as Ports
import Gameroom.Spec as Spec
import Models.Main exposing (Model)
import Models.IncomingMessage as InMsg


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
                Time.every Consts.gameTick (\time -> Messages.GameMsgC (GameMessages.Tick time))

            _ ->
                Sub.none
        ]
