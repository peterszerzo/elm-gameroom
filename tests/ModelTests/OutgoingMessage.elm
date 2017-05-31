module ModelTests.OutgoingMessage exposing (..)

import Test exposing (..)
import Expect
import Models.Room as Room
import Json.Decode as JD
import Json.Encode as JE
import Models.OutgoingMessage exposing (OutgoingMessage(..), encoder)


type alias Problem =
    String


problemEncoder : Problem -> JE.Value
problemEncoder =
    JE.string


type alias Guess =
    String


guessEncoder : Guess -> JE.Value
guessEncoder =
    JE.string


testRoom : Room.Room Problem Guess
testRoom =
    Room.create "room" [ "player1", "player2" ]


tests : Test
tests =
    describe "OutgoingMessage"
        [ describe "encoder"
            [ test "adds correct type value to CreateRoom message" <|
                \() ->
                    CreateRoom testRoom
                        |> encoder problemEncoder guessEncoder
                        |> JD.decodeValue (JD.at [ "type" ] JD.string)
                        |> Result.map ((==) "create:room")
                        |> Result.withDefault False
                        |> Expect.equal True
            , test "adds correct type value to UpdateRoom message" <|
                \() ->
                    UpdateRoom testRoom
                        |> encoder problemEncoder guessEncoder
                        |> JD.decodeValue (JD.at [ "type" ] JD.string)
                        |> Result.map ((==) "update:room")
                        |> Result.withDefault False
                        |> Expect.equal True
            ]
        ]
