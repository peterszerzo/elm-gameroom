module Gameroom.Subscriptions exposing (..)

import Time
import Json.Decode as JD
import Gameroom.Messages as Messages
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Modules.NewRoom.Messages as NewRoomMessages
import Gameroom.Router as Router
import Gameroom.Models.Room as Room
import Gameroom.Models.Player as Player
import Gameroom.Ports as Ports
import Gameroom.Models.Main exposing (Model)


type Subscription problem guess
    = RoomCreated (Room.Room problem guess)
    | RoomUpdated (Room.Room problem guess)
    | PlayerUpdated (Player.Player guess)


subscriptionDecoder : JD.Decoder problem -> JD.Decoder guess -> JD.Decoder (Subscription problem guess)
subscriptionDecoder problemDecoder guessDecoder =
    JD.map2 (\type_ payload -> ( type_, payload ))
        (JD.field "type" JD.string)
        (JD.field "payload" JD.value)
        |> JD.andThen
            (\( type_, payload ) ->
                case type_ of
                    "room:created" ->
                        JD.decodeValue (Room.decoder problemDecoder guessDecoder) payload
                            |> Result.map (\room -> JD.succeed (RoomCreated room))
                            |> Result.withDefault (JD.fail "Failed to decode created room.")

                    "room:updated" ->
                        JD.decodeValue (Room.decoder problemDecoder guessDecoder) payload
                            |> Result.map (\room -> JD.succeed (RoomUpdated room))
                            |> Result.withDefault (JD.fail "Failed to decode updated room.")

                    "player:updated" ->
                        JD.decodeValue (Player.decoder guessDecoder) payload
                            |> Result.map (\player -> JD.succeed (PlayerUpdated player))
                            |> Result.withDefault (JD.fail "Failed to decode updated player.")

                    _ ->
                        JD.fail "1234"
            )


subscriptions : Ports.Ports (Messages.Msg problem guess) -> Model problem guess -> Sub (Messages.Msg problem guess)
subscriptions ports model =
    Sub.batch
        [ ports.roomUpdated (\val -> Messages.GameMsgC (GameMessages.ReceiveUpdate val))
        , case model.route of
            Router.Game _ ->
                Time.every (20000 * Time.millisecond) (\time -> Messages.GameMsgC (GameMessages.Tick time))

            Router.NewRoomRoute _ ->
                ports.roomCreated (\msg -> Messages.NewRoomMsgC (NewRoomMessages.CreateResponse msg))

            _ ->
                Sub.none
        ]
