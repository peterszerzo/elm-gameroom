module Gameroom.Models.OutgoingMessage exposing (..)

import Json.Encode as JE
import Gameroom.Models.Room as Room
import Gameroom.Models.Player as Player


type OutgoingMessage problem guess
    = CreateRoom (Room.Room problem guess)
    | UpdateRoom (Room.Room problem guess)
    | UpdatePlayer (Player.Player guess)
    | SubscribeToRoom String
    | UnsubscribeFromRoom String


encoder :
    (problem -> JE.Value)
    -> (guess -> JE.Value)
    -> OutgoingMessage problem guess
    -> JE.Value
encoder problemEncoder guessEncoder cmd =
    case cmd of
        CreateRoom room ->
            JE.object
                [ ( "type", JE.string "create:room" )
                , ( "payload", Room.encoder problemEncoder guessEncoder room )
                ]

        UpdateRoom room ->
            JE.object
                [ ( "type", JE.string "update:room" )
                , ( "payload", Room.encoder problemEncoder guessEncoder room )
                ]

        UpdatePlayer player ->
            JE.object
                [ ( "type", JE.string "update:player" )
                , ( "payload", Player.encoder guessEncoder player )
                ]

        SubscribeToRoom roomId ->
            JE.object
                [ ( "type", JE.string "subscribeto:room" )
                , ( "payload", JE.string roomId )
                ]

        UnsubscribeFromRoom roomId ->
            JE.object
                [ ( "type", JE.string "unsubscribefrom:room" )
                , ( "payload", JE.string roomId )
                ]
