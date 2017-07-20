module Tests.Data.Player exposing (..)

import Test exposing (..)
import Expect
import Json.Decode as JD
import Data.Player as Player


tests : Test
tests =
    describe "Player"
        [ describe "decoder"
            [ test "decodes player with no current guess" <|
                \() ->
                    "{\"id\": \"player\", \"roomId\": \"room\", \"isReady\": false, \"score\": 0, \"guess\": \"__elm-gameroom__null__\"}"
                        |> JD.decodeString (Player.decoder JD.int)
                        |> Result.map (\player -> player.guess == Nothing)
                        |> Result.withDefault False
                        |> Expect.equal True
            , test "decodes player with current guess" <|
                \() ->
                    "{\"id\": \"player\", \"roomId\": \"room\", \"isReady\": false, \"score\": 0, \"guess\": {\"value\": 2, \"madeAt\": 3}}"
                        |> JD.decodeString (Player.decoder JD.int)
                        |> Result.map (\player -> player.guess |> Maybe.map .value |> Maybe.map ((==) 2) |> Maybe.withDefault False)
                        |> Result.withDefault False
                        |> Expect.equal True
            ]
        ]
