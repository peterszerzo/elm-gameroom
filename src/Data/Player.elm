module Data.Player exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Data.Guess as Guess


type alias PlayerId =
    String


type alias Player guess =
    { id : String
    , roomId : String
    , isReady : Bool
    , score : Int
    , guess :
        Maybe (Guess.Guess guess)
    }


type alias Players guess =
    Dict.Dict String (Player guess)


create : String -> String -> Player guess
create id roomId =
    { id = id
    , roomId = roomId
    , isReady = False
    , score = 0
    , guess = Nothing
    }


extractGuesses : List ( String, Player guess ) -> List ( String, guess )
extractGuesses players =
    case players of
        [] ->
            []

        ( playerId, player ) :: tail ->
            (case player.guess of
                Just guess ->
                    [ ( playerId, guess.value ) ]

                Nothing ->
                    []
            )
                ++ (extractGuesses tail)



-- Encoders


encoder : (guess -> JE.Value) -> (Player guess -> JE.Value)
encoder guessEncoder player =
    JE.object <|
        [ ( "id", JE.string player.id )
        , ( "roomId", JE.string player.roomId )
        , ( "isReady", JE.bool player.isReady )
        , ( "score", JE.int player.score )
        ]
            ++ (player.guess
                    |> Maybe.map
                        (\guess ->
                            [ ( "guess"
                              , JE.object
                                    [ ( "value", guessEncoder guess.value )
                                    , ( "madeAt", JE.float guess.madeAt )
                                    ]
                              )
                            ]
                        )
                    |> Maybe.withDefault []
               )


collectionEncoder : (guess -> JE.Value) -> (Players guess -> JE.Value)
collectionEncoder guessEncoder players =
    players
        |> Dict.toList
        |> List.map (\( key, player ) -> ( key, encoder guessEncoder player ))
        |> JE.object



-- Decoders


decoder : JD.Decoder guess -> JD.Decoder (Player guess)
decoder guessDecoder =
    JD.map5 Player
        (JD.field "id" JD.string)
        (JD.field "roomId" JD.string)
        (JD.field "isReady" JD.bool)
        (JD.field "score" JD.int)
        (JD.maybe (JD.field "guess" (Guess.decoder guessDecoder)))
