module Gameroom.Spec exposing (..)

{-| With the Spec object, you can define your game declaratively, specifying only what is unique to it.

# The full spec
@docs Spec

# The view
@docs View

# Game logic
@docs IsGuessCorrect, ProblemGenerator

# Data management
@docs ProblemEncoder, ProblemDecoder, GuessEncoder, GuessDecoder
-}

import Html
import Random
import Json.Decode as Decode
import Json.Encode as Encode
import Models.Player exposing (PlayerId, Players)


{-| Define every moving part of a multiplayer game:

    type alias Spec problem guess =
        { view : PlayerId -> Players guess -> problem -> Html.Html guess
        , isGuessCorrect : problem -> guess -> Bool
        , problemGenerator : Random.Generator problem
        , problemEncoder : problem -> JE.Value
        , problemDecoder : JD.Decoder problem
        , guessEncoder : guess -> JE.Value
        , guessDecoder : JD.Decoder guess
        }
-}
type alias Spec problem guess =
    { view : View problem guess
    , isGuessCorrect : IsGuessCorrect problem guess
    , problemGenerator : ProblemGenerator problem
    , problemEncoder : ProblemEncoder problem
    , problemDecoder : ProblemDecoder problem
    , guessEncoder : GuessEncoder guess
    , guessDecoder : GuessDecoder guess
    }


{-| Game view, based on current player, all players, current time in round, and the current problem. Emits guesses.
-}
type alias View problem guess =
    PlayerId -> Players guess -> Int -> problem -> Html.Html guess


{-| Determines whether a guess is correct.
-}
type alias IsGuessCorrect problem guess =
    problem -> guess -> Bool


{-| Generate game problems.
-}
type alias ProblemGenerator problem =
    Random.Generator problem


{-| Encode a problem to be stored in the backend.
-}
type alias ProblemEncoder problem =
    problem -> Encode.Value


{-| Decode a problem as it arrives from the backend.
-}
type alias ProblemDecoder problem =
    Decode.Decoder problem


{-| Encode a guess to be stored in the backend.
-}
type alias GuessEncoder guess =
    guess -> Encode.Value


{-| Decode a guess as it arrives from the backend.
-}
type alias GuessDecoder guess =
    Decode.Decoder guess
