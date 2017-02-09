module Update exposing (update)

import Messages exposing (Msg(..))
import Models exposing (Model, Spec)
import Json.Decode as JD


update : Spec problemType guessType -> Msg guessType -> Model problemType guessType -> ( Model problemType guessType, Cmd (Msg guessType) )
update spec msg model =
    case msg of
        ReceiveUpdate roomString ->
            let
                roomRes =
                    roomString
                        |> JD.decodeString (Models.roomDecoder spec.problemDecoder spec.guessDecoder)
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
