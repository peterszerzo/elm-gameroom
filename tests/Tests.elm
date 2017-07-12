module Tests exposing (..)

import Test exposing (..)
import Tests.Utils
import Tests.Data.Room
import Tests.Data.Player
import Tests.Data.OutgoingMessage


all : Test
all =
    describe "elm-gameroom"
        [ Tests.Utils.tests
        , Tests.Data.Room.tests
        , Tests.Data.Player.tests
        , Tests.Data.OutgoingMessage.tests
        ]
