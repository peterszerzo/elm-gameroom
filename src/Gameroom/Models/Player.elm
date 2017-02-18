module Gameroom.Models.Player exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Gameroom.Models.Guess as Guess


type alias Player guessType =
    { id : String
    , isReady : Bool
    , score : Int
    , guess :
        Maybe (Guess.GuessWithTimestamp guessType)
    }


type alias Players guessType =
    Dict.Dict String (Player guessType)


create : String -> Player guessType
create id =
    { id = id
    , isReady = False
    , score = 0
    , guess = Nothing
    }



-- Encoders


encoder : (guessType -> JE.Value) -> (Player guessType -> JE.Value)
encoder guessEncoder player =
    JE.object
        [ ( "id", JE.string player.id )
        , ( "isReady", JE.bool player.isReady )
        , ( "score", JE.int player.score )
        , ( "guess"
          , case player.guess of
                Nothing ->
                    JE.string "null"

                Just guess ->
                    JE.object [ ( "value", guessEncoder guess.value ), ( "madeAt", JE.float guess.madeAt ) ]
          )
        ]


collectionEncoder : (guessType -> JE.Value) -> (Players guessType -> JE.Value)
collectionEncoder guessEncoder players =
    players
        |> Dict.toList
        |> List.map (\( key, player ) -> ( key, encoder guessEncoder player ))
        |> JE.object



-- Decoders


decoder : JD.Decoder guessType -> JD.Decoder (Player guessType)
decoder guessDecoder =
    JD.map4 Player
        (JD.field "id" JD.string)
        (JD.field "isReady" JD.bool)
        (JD.field "score" JD.int)
        (JD.field "guess"
            (JD.oneOf
                [ JD.string
                    |> JD.andThen
                        (\s ->
                            if s == "null" then
                                JD.succeed Nothing
                            else
                                JD.fail "Guess not recognized"
                        )
                ]
            )
        )
