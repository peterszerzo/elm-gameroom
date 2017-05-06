module ModelTests.Room exposing (..)

import Test exposing (..)
import Dict
import Expect
import Models.Room as Room


tests : Test
tests =
    describe "Room"
        [ describe "allPlayersReady"
            [ test "returns True on empty players" <|
                \() ->
                    Room.allPlayersReady
                        { id = "123"
                        , host = "456"
                        , round = Nothing
                        , players = Dict.empty
                        }
                        |> Expect.equal True
            ]
        , describe "updatePreservingLocalGuesses"
            [ test "preserves if round did not change" <|
                \() ->
                    (Room.updatePreservingLocalGuesses
                        { id = "123"
                        , host = "456"
                        , round = Just { no = 1, problem = "1234" }
                        , players =
                            Dict.fromList
                                [ ( "player1"
                                  , { id = "player1"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess = Nothing
                                    }
                                  )
                                , ( "player2"
                                  , { id = "player2"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess =
                                        Nothing
                                    }
                                  )
                                ]
                        }
                        { id = "123"
                        , host = "456"
                        , round = Just { no = 1, problem = "1234" }
                        , players =
                            Dict.fromList
                                [ ( "player1"
                                  , { id = "player1"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess = Nothing
                                    }
                                  )
                                , ( "player2"
                                  , { id = "player2"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess =
                                        Just
                                            { value = 0
                                            , madeAt = 100
                                            }
                                    }
                                  )
                                ]
                        }
                        |> .players
                        |> Dict.get "player2"
                        |> Maybe.andThen .guess
                        |> Maybe.map .value
                        |> Expect.equal (Just 0)
                    )
            , test "does not preserve if round changed" <|
                \() ->
                    (Room.updatePreservingLocalGuesses
                        { id = "123"
                        , host = "456"
                        , round = Just { no = 2, problem = "1324" }
                        , players =
                            Dict.fromList
                                [ ( "player1"
                                  , { id = "player1"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess = Nothing
                                    }
                                  )
                                , ( "player2"
                                  , { id = "player2"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess =
                                        Nothing
                                    }
                                  )
                                ]
                        }
                        { id = "123"
                        , host = "456"
                        , round = Just { no = 1, problem = "1234" }
                        , players =
                            Dict.fromList
                                [ ( "player1"
                                  , { id = "player1"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess = Nothing
                                    }
                                  )
                                , ( "player2"
                                  , { id = "player2"
                                    , roomId = "123"
                                    , isReady = True
                                    , score = 0
                                    , guess =
                                        Just
                                            { value = 0
                                            , madeAt = 100
                                            }
                                    }
                                  )
                                ]
                        }
                        |> .players
                        |> Dict.get "player2"
                        |> Maybe.andThen .guess
                        |> Maybe.map .value
                        |> Expect.equal Nothing
                    )
            ]
        ]
