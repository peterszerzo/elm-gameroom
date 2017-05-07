module Gameroom.Spec exposing (..)

{-| With the Spec object, you can define your game declaratively, specifying only what is unique to it.

# The full spec
@docs Spec

# The view
@docs View, Copy

# Game logic
@docs ProblemGenerator

# Data management
@docs ProblemEncoder, ProblemDecoder, GuessEncoder, GuessDecoder
-}

import Html
import Random
import Json.Decode as Decode
import Json.Encode as Encode
import Models.Player exposing (PlayerId, Players)


{-| Define every moving part of a multiplayer game, all generalized over a type variable representing a `problem`, and one representing a `guess`. Each field in the record is documented separately in this module.
-}
type alias Spec problem guess =
    { copy : Copy
    , view : View problem guess
    , isGuessCorrect : problem -> guess -> Bool
    , problemGenerator : ProblemGenerator problem
    , problemEncoder : ProblemEncoder problem
    , problemDecoder : ProblemDecoder problem
    , guessEncoder : GuessEncoder guess
    , guessDecoder : GuessDecoder guess
    }


{-| Some copy to populate the game's interface. Includes the game title, subheading and instruction.

    copy =
        { name = "Simple Game"
        , subheading = "You don't want to play this one.."
        , instructions = "Just hit no!"
        }
-}
type alias Copy =
    { name : String
    , subheading : String
    , instructions : String
    }


{-| Game view, based on current player, all players, current number of repaints since the round began, and the current problem. Emits guesses.
-}
type alias View problem guess =
    PlayerId -> Players guess -> Int -> problem -> Html.Html guess


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
