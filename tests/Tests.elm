module Tests exposing (..)

import Test exposing (..)
import ModelTests.Room
import ModelTests.Player
import ModelTests.OutgoingMessage


all : Test
all =
    describe "elm-gameroom"
        [ ModelTests.Room.tests
        , ModelTests.Player.tests
        , ModelTests.OutgoingMessage.tests
        ]
