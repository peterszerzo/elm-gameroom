module Models.Spec exposing (..)

{-| With the Spec object, you can define your game declaratively, specifying only what is unique to it.

# The full spec
@docs Spec

# The view
@docs View, Ticks, Copy

# Game logic
@docs ProblemGenerator

# Data management
@docs ProblemEncoder, ProblemDecoder, GuessEncoder, GuessDecoder
-}

import Html
import Random
import Json.Decode as Decode
import Json.Encode as Encode
import Gameroom.Context exposing (Context)


type Option
    = BaseUrl String
    | Name String
    | Subheading String
    | Instructions String
    | Icon String


{-| Define the basic mechanics of a multiplayer game, all generalized over a type variable representing a `problem`, and one representing a `guess`. Each field in the record is documented separately in this module.
-}
type alias Spec problem guess =
    { view : View problem guess
    , isGuessCorrect : problem -> guess -> Bool
    , problemGenerator : ProblemGenerator problem
    , problemEncoder : ProblemEncoder problem
    , problemDecoder : ProblemDecoder problem
    , guessEncoder : GuessEncoder guess
    , guessDecoder : GuessDecoder guess
    }


{-| Augments the spec with data from options.
-}
type alias DetailedSpec problem guess =
    { baseUrl : Maybe String
    , icon : String
    , name : String
    , subheading : String
    , instructions : String
    , view : View problem guess
    , isGuessCorrect : problem -> guess -> Bool
    , problemGenerator : ProblemGenerator problem
    , problemEncoder : ProblemEncoder problem
    , problemDecoder : ProblemDecoder problem
    , guessEncoder : GuessEncoder guess
    , guessDecoder : GuessDecoder guess
    }


buildDetailedSpec : List Option -> Spec problem guess -> DetailedSpec problem guess
buildDetailedSpec options spec =
    List.foldl
        (\option spec ->
            case option of
                BaseUrl baseUrl ->
                    { spec | baseUrl = Just baseUrl }

                Name name ->
                    { spec | name = name }

                Subheading subheading ->
                    { spec | subheading = subheading }

                Instructions instructions ->
                    { spec | instructions = instructions }

                Icon icon ->
                    { spec | icon = icon }
        )
        { baseUrl = Nothing
        , icon = "\x1F3D3"
        , name = "Game"
        , subheading = "A great game to play with your friends"
        , instructions = "Win the game!"
        , view = spec.view
        , isGuessCorrect = spec.isGuessCorrect
        , problemGenerator = spec.problemGenerator
        , problemEncoder = spec.problemEncoder
        , problemDecoder = spec.problemDecoder
        , guessEncoder = spec.guessEncoder
        , guessDecoder = spec.guessDecoder
        }
        options


{-| Counts the number of repaints using `AnimationFrame`.
-}
type alias Ticks =
    Int


{-| The core of the View of the current game round, excluding all navigation, notifications and the score boards. Emits guesses.

The arguments in order, are the following:
* context: see [Context](/Gameroom-Context) docs.
* problem: the current game problem.
-}
type alias View problem guess =
    Context guess -> problem -> Html.Html guess


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
