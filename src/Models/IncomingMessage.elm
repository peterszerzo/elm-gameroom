module Models.IncomingMessage exposing (..)

import Json.Decode as JD
import Models.Room as Room
import Models.Player as Player


type IncomingMessage problem guess
    = RoomCreated (Room.Room problem guess)
    | RoomUpdated (Room.Room problem guess)


decoder : JD.Decoder problem -> JD.Decoder guess -> JD.Decoder (IncomingMessage problem guess)
decoder problemDecoder guessDecoder =
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

                    _ ->
                        JD.fail "1234"
            )
