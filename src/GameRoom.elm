module GameRoom exposing (..)

import Html exposing (Html, beginnerProgram, div, text)
import Json.Encode as JE
import Json.Decode as JD
import Ports


-- Models


type alias Spec problemType guessType =
    { view : Model problemType guessType -> Html (Msg guessType)
    , isGuessCorrect : problemType -> guessType -> Bool
    , guessEncoder : guessType -> JE.Value
    , guessDecoder : JD.Decoder guessType
    , problemEncoder : problemType -> JE.Value
    , problemDecoder : JD.Decoder problemType
    }


type alias Model problemType guessType =
    { guess : Maybe guessType
    , problem : Maybe problemType
    }



-- Messages


type Msg guessType
    = Guess guessType
    | Disconnect
    | ReceiveUpdate String



-- Program


program : Spec problemType guessType -> Program Never (Model problemType guessType) (Msg guessType)
program { view, isGuessCorrect } =
    Html.program
        { init = ( { guess = Nothing, problem = Nothing }, Cmd.none )
        , view = view
        , update =
            (\msg model ->
                case msg of
                    Guess guess ->
                        ( { model | guess = Just guess }, Ports.update (toString model) )

                    _ ->
                        ( model, Cmd.none )
            )
        , subscriptions =
            (\model -> Ports.updated ReceiveUpdate)
        }
