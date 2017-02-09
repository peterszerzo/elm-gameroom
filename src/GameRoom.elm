module GameRoom exposing (..)

import Html exposing (Html, map, beginnerProgram, div, text)
import Json.Encode as JE
import Json.Decode as JD
import Ports
import Models


-- Models


type alias Spec problemType guessType =
    { view : Models.Model problemType guessType -> Html guessType
    , isGuessCorrect : problemType -> guessType -> Bool
    , guessEncoder : guessType -> JE.Value
    , guessDecoder : JD.Decoder guessType
    , problemEncoder : problemType -> JE.Value
    , problemDecoder : JD.Decoder problemType
    }



-- Messages


type Msg guessType
    = Guess guessType
    | Disconnect
    | ReceiveUpdate String



-- Program


program :
    Spec problemType guessType
    -> Program Never (Models.Model problemType guessType) (Msg guessType)
program { view, isGuessCorrect, guessDecoder, problemDecoder } =
    Html.program
        { init = ( { playerId = "alfred", room = Nothing }, Cmd.none )
        , view = (map Guess) << view
        , update =
            (\msg model ->
                case msg of
                    ReceiveUpdate roomString ->
                        let
                            roomRes =
                                roomString
                                    |> JD.decodeString (Models.roomDecoder problemDecoder guessDecoder)
                                    |> Result.toMaybe
                        in
                            ( { model | room = roomRes }, Cmd.none )

                    Guess guess ->
                        let
                            _ =
                                Debug.log "guess" guess
                        in
                            ( model, Cmd.none )

                    _ ->
                        ( model, Cmd.none )
            )
        , subscriptions =
            (\model -> Ports.updated ReceiveUpdate)
        }
