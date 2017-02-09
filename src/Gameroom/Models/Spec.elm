module Models.Spec exposing (..)

import Html
import Json.Decode as JD
import Json.Encode as JE
import Models.Room exposing (Room)


-- Client-defined game spec


type alias Spec problemType guessType =
    { view : String -> Room problemType guessType -> Html.Html guessType
    , isGuessCorrect : problemType -> guessType -> Bool
    , guessEncoder : guessType -> JE.Value
    , guessDecoder : JD.Decoder guessType
    , problemEncoder : problemType -> JE.Value
    , problemDecoder : JD.Decoder problemType
    }
