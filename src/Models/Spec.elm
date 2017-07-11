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
import Time
import Random
import Json.Decode as Decode
import Json.Encode as Encode
import Gameroom.Context exposing (Context)


type Setting
    = BasePath String
    | Name String
    | Subheading String
    | Instructions String
    | Icon String
    | RoundDuration Time.Time
    | CooldownDuration Time.Time
    | ClearWinner Float


{-| Define the basic mechanics of a multiplayer game, all generalized over a type variable representing a `problem`, and one representing a `guess`. Each field in the record is documented separately in this module.
-}
type alias Spec problem guess =
    { view : Context guess -> problem -> Html.Html guess
    , evaluate : problem -> guess -> Time.Time -> Float
    , problemGenerator : Random.Generator problem
    , problemEncoder : problem -> Encode.Value
    , problemDecoder : Decode.Decoder problem
    , guessEncoder : guess -> Encode.Value
    , guessDecoder : Decode.Decoder guess
    }


{-| Augments the spec with data from options.
-}
type alias DetailedSpec problem guess =
    { basePath : String
    , icon : String
    , name : String
    , subheading : String
    , instructions : String
    , roundDuration : Time.Time
    , cooldownDuration : Time.Time
    , clearWinnerEvaluation : Maybe Float
    , view : Context guess -> problem -> Html.Html guess
    , evaluate : problem -> guess -> Time.Time -> Float
    , problemGenerator : Random.Generator problem
    , problemEncoder : problem -> Encode.Value
    , problemDecoder : Decode.Decoder problem
    , guessEncoder : guess -> Encode.Value
    , guessDecoder : Decode.Decoder guess
    }


buildDetailedSpec : List Setting -> Spec problem guess -> DetailedSpec problem guess
buildDetailedSpec options spec =
    List.foldl
        (\option spec ->
            case option of
                BasePath basePath ->
                    let
                        baseSlug =
                            basePath
                                |> (\path_ ->
                                        -- Remove leading slash
                                        if String.left 1 path_ == "/" then
                                            String.dropLeft 1 path_
                                        else
                                            path_
                                   )
                                |> (\path_ ->
                                        -- Remove trailing slash
                                        if String.right 1 path_ == "/" then
                                            String.dropRight 1 path_
                                        else
                                            path_
                                   )
                    in
                        { spec | basePath = "/" ++ baseSlug }

                Name name ->
                    { spec | name = name }

                Subheading subheading ->
                    { spec | subheading = subheading }

                Instructions instructions ->
                    { spec | instructions = instructions }

                Icon icon ->
                    { spec | icon = icon }

                RoundDuration duration ->
                    { spec | roundDuration = duration }

                CooldownDuration duration ->
                    { spec | cooldownDuration = duration }

                ClearWinner maxEvaluation ->
                    { spec | clearWinnerEvaluation = Just maxEvaluation }
        )
        { basePath = "/"
        , icon = "\x1F3D3"
        , name = "Game"
        , subheading = "A great game to play with your friends"
        , instructions = "Win the game!"
        , roundDuration = 4 * Time.second
        , cooldownDuration = 2 * Time.second
        , clearWinnerEvaluation = Nothing
        , view = spec.view
        , evaluate = spec.evaluate
        , problemGenerator = spec.problemGenerator
        , problemEncoder = spec.problemEncoder
        , problemDecoder = spec.problemDecoder
        , guessEncoder = spec.guessEncoder
        , guessDecoder = spec.guessDecoder
        }
        options
