module Tests exposing (..)

import Test exposing (..)
import ModelTests.Room


all : Test
all =
    describe "elm-gameroom"
        [ ModelTests.Room.tests ]
