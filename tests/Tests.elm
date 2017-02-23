module Tests exposing (..)

import Test exposing (..)
import Dict
import Expect
import Gameroom.Models.Room as Room


all : Test
all =
    describe "elm-gameroom"
        [ describe "Room"
            [ test "allPlayersReady on empty players" <|
                \() ->
                    Room.allPlayersReady
                        { id = "123"
                        , host = "456"
                        , round = { no = 0, problem = Nothing }
                        , players = Dict.empty
                        }
                        |> Expect.equal True
            ]
        ]
