module Gameroom.Models.Spec exposing (..)

import Html
import Random
import Json.Decode as JD
import Json.Encode as JE
import Gameroom.Models.Room exposing (Room)


-- Client-defined game spec


type alias Spec problemType guessType =
    { view : String -> Room problemType guessType -> Html.Html guessType
    , isGuessCorrect : problemType -> guessType -> Bool
    , problemGenerator : Random.Generator problemType
    , problemEncoder : Maybe problemType -> JE.Value
    , problemDecoder : JD.Decoder (Maybe problemType)
    , guessEncoder : guessType -> JE.Value
    , guessDecoder : JD.Decoder guessType
    }
