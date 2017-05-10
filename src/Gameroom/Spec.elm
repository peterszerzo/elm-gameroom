module Gameroom.Spec exposing (..)

{-| With the Spec object, you can define your game declaratively, specifying only what is unique to it.

# The full spec
@docs Spec

# The view
@docs View, Ticks, Copy, RoundResult, Status

# Game logic
@docs ProblemGenerator

# Data management
@docs ProblemEncoder, ProblemDecoder, GuessEncoder, GuessDecoder
-}

import Html
import Dict
import Window
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


{-| The result of the current game round, either pending, with a winner, or with a tie. This is useful so that the client may display feedback on the opponent's guess once the round is over.
-}
type RoundResult
    = Pending
    | Winner String
    | Tie


{-| Counts the number of repaints using `AnimationFrame`.
-}
type alias Ticks =
    Int


{-| Game room status information passed to the view. Contains own player, a dictionary of guesses, and the round result.
-}
type alias Status guess =
    { playerId : PlayerId
    , guesses : Dict.Dict String guess
    , roundResult : RoundResult
    }


{-| The core of the View of the current game round, excluding all navigation, notifications and the score boards. Emits guesses.

The arguments in order, are the following:
* windowSize: the size of the window as per the `elm-lang/window` package (e.g. `{ width = 500, height = 300 }`).
* animationTicksSinceNewRound: the number of repaints since the round started.
* playerId: string id of the player.
* players: a dictionary with all players. Example player: { id = "samantha", guess = { value = 3, madeAt = 11 } }
* problem: the current game problem.
-}
type alias View problem guess =
    Window.Size -> Ticks -> Status guess -> problem -> Html.Html guess


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
