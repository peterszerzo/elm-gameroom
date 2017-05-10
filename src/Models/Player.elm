module Models.Player exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Models.Guess as Guess
import Models.RoomId exposing (RoomId)
import Constants exposing (nullString)


type alias PlayerId =
    String


type alias Player guess =
    { id : PlayerId
    , roomId : RoomId
    , isReady : Bool
    , score : Int
    , guess :
        Maybe (Guess.Guess guess)
    }


type alias Players guess =
    Dict.Dict PlayerId (Player guess)


create : PlayerId -> RoomId -> Player guess
create id roomId =
    { id = id
    , roomId = roomId
    , isReady = False
    , score = 0
    , guess = Nothing
    }


extractGuesses : List ( PlayerId, Player guess ) -> List ( PlayerId, guess )
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
    JE.object
        [ ( "id", JE.string player.id )
        , ( "roomId", JE.string player.roomId )
        , ( "isReady", JE.bool player.isReady )
        , ( "score", JE.int player.score )
        , ( "guess"
          , case player.guess of
                Nothing ->
                    JE.string nullString

                Just guess ->
                    JE.object [ ( "value", guessEncoder guess.value ), ( "madeAt", JE.int guess.madeAt ) ]
          )
        ]


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
        (JD.field "guess"
            (JD.oneOf
                [ JD.string
                    |> JD.andThen
                        (\s ->
                            if s == nullString then
                                JD.succeed Nothing
                            else
                                JD.fail "Guess not recognized"
                        )
                , Guess.decoder guessDecoder
                    |> JD.andThen (\g -> JD.succeed (Just g))
                ]
            )
        )
