module Gameroom.Subscriptions exposing (..)

import Time
import Json.Decode as JD
import Gameroom.Messages as Messages
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Router as Router
import Gameroom.Models.Ports as Ports
import Gameroom.Spec as Spec
import Gameroom.Models.Main exposing (Model)
import Gameroom.Models.IncomingMessage as InMsg


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
                Time.every (20000 * Time.millisecond) (\time -> Messages.GameMsgC (GameMessages.Tick time))

            _ ->
                Sub.none
        ]
