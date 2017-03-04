module Gameroom.Spec exposing (..)

{-| Game Spec - define your game declaratively, with none of the boilerplate.

What does a multiplayer guessing game need?

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
import Gameroom.Models.Player exposing (PlayerId, Players)


{-| Define every moving part of a multiplayer game:

    type alias Spec problemType guessType =
        { view : PlayerId -> Players guessType -> problemType -> Html.Html guessType
        , isGuessCorrect : problemType -> guessType -> Bool
        , problemGenerator : Random.Generator problemType
        , problemEncoder : problemType -> JE.Value
        , problemDecoder : JD.Decoder problemType
        , guessEncoder : guessType -> JE.Value
        , guessDecoder : JD.Decoder guessType
        }
-}
type alias Spec problemType guessType =
    { view : View problemType guessType
    , isGuessCorrect : IsGuessCorrect problemType guessType
    , problemGenerator : ProblemGenerator problemType
    , problemEncoder : ProblemEncoder problemType
    , problemDecoder : ProblemDecoder problemType
    , guessEncoder : GuessEncoder guessType
    , guessDecoder : GuessDecoder guessType
    }


{-| Game view, based on current player, all players, and the current problem. Emits guesses.
-}
type alias View problemType guessType =
    PlayerId -> Players guessType -> problemType -> Html.Html guessType


{-| Determines whether a guess is correct.
-}
type alias IsGuessCorrect problemType guessType =
    problemType -> guessType -> Bool


{-| Generate game problems.
-}
type alias ProblemGenerator problemType =
    Random.Generator problemType


{-| Encode a problem to be stored in the backend.
-}
type alias ProblemEncoder problemType =
    problemType -> Encode.Value


{-| Decode a problem as it arrives from the backend.
-}
type alias ProblemDecoder problemType =
    Decode.Decoder problemType


{-| Encode a guess to be stored in the backend.
-}
type alias GuessEncoder guessType =
    guessType -> Encode.Value


{-| Decode a guess as it arrives from the backend.
-}
type alias GuessDecoder guessType =
    Decode.Decoder guessType
