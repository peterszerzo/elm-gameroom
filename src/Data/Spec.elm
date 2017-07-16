module Data.Spec exposing (..)

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
import Messages exposing (Msg)
import Data.Ports as Ports
import Json.Decode as Decode
import Json.Encode as Encode
import Gameroom.Context exposing (Context)


type Setting problem guess
    = BasePath String
    | Name String
    | Subheading String
    | Instructions String
    | Icon String
    | RoundDuration Time.Time
    | CooldownDuration Time.Time
    | ClearWinner Float
    | SetPorts (Ports.Ports (Msg problem guess))
    | NoInlineStyle
    | NoPeripheralUi


{-| Define the basic mechanics of a multiplayer game, all generalized over a type variable representing a `problem`, and one representing a `guess`. Each field in the record is documented separately in this module.
-}
type alias Spec problem guess =
    { view : Context guess -> problem -> Html.Html guess
    , evaluate : problem -> guess -> Float
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
    , ports : Ports.Ports (Msg problem guess)
    , inlineStyle : Bool
    , peripheralUi : Bool
    , view : Context guess -> problem -> Html.Html guess
    , evaluate : problem -> guess -> Float
    , problemGenerator : Random.Generator problem
    , problemEncoder : problem -> Encode.Value
    , problemDecoder : Decode.Decoder problem
    , guessEncoder : guess -> Encode.Value
    , guessDecoder : Decode.Decoder guess
    }


buildDetailedSpec : List (Setting problem guess) -> Spec problem guess -> DetailedSpec problem guess
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

                SetPorts p ->
                    { spec | ports = p }

                NoInlineStyle ->
                    { spec | inlineStyle = False }

                NoPeripheralUi ->
                    { spec | peripheralUi = False }
        )
        { basePath = "/"
        , icon = "\x1F3D3"
        , name = "Game"
        , subheading = "A great game to play with your friends"
        , instructions = "Win the game!"
        , roundDuration = 4 * Time.second
        , cooldownDuration = 2 * Time.second
        , clearWinnerEvaluation = Nothing
        , ports = Ports.init
        , view = spec.view
        , inlineStyle = True
        , peripheralUi = True
        , evaluate = spec.evaluate
        , problemGenerator = spec.problemGenerator
        , problemEncoder = spec.problemEncoder
        , problemDecoder = spec.problemDecoder
        , guessEncoder = spec.guessEncoder
        , guessDecoder = spec.guessDecoder
        }
        options
