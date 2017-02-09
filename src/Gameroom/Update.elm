module Update exposing (..)

import Navigation
import Messages exposing (Msg(..))
import Models.Main exposing (Model)
import Models.Room as Room
import Models.Spec exposing (Spec)
import Json.Decode as JD
import Ports
import Router


cmdOnRouteChange : Router.Route problemType guessType -> Cmd (Msg problemType guessType)
cmdOnRouteChange route =
    case route of
        Router.Game roomId playerId Nothing ->
            Ports.connectToRoom roomId

        _ ->
            Cmd.none


update : Spec problemType guessType -> Msg problemType guessType -> Model problemType guessType -> ( Model problemType guessType, Cmd (Msg problemType guessType) )
update spec msg model =
    case msg of
        ReceiveUpdate roomString ->
            let
                roomRes =
                    roomString
                        |> JD.decodeString (Room.decoder spec.problemDecoder spec.guessDecoder)
                        |> Result.toMaybe
            in
                ( { model | room = roomRes }, Cmd.none )

        Guess guess ->
            let
                _ =
                    Debug.log "guess" guess
            in
                ( model, Cmd.none )

        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange route
            )

        Navigate newUrl ->
            ( model, Navigation.newUrl newUrl )

        _ ->
            ( model, Cmd.none )
