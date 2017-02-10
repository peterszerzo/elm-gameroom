module Update exposing (..)

import Navigation
import Random
import Messages exposing (Msg(..))
import Models.Main exposing (Model)
import Models.Room as Room
import Models.Spec exposing (Spec)
import Json.Decode as JD
import Ports
import Router


cmdOnRouteChange : Router.Route problemType guessType -> Maybe (Router.Route problemType guessType) -> Cmd (Msg problemType guessType)
cmdOnRouteChange route maybePreviousRoute =
    case route of
        Router.Game roomId playerId Nothing ->
            Ports.connectToRoom roomId

        _ ->
            Cmd.none


updateGameRoom : (Maybe (Room.Room problemType guessType) -> Maybe (Room.Room problemType guessType)) -> Model problemType guessType -> Model problemType guessType
updateGameRoom mapRm model =
    { model
        | route =
            case model.route of
                Router.Game roomId playerId room ->
                    Router.Game roomId playerId (mapRm room)

                _ ->
                    model.route
    }


update : Spec problemType guessType -> Msg problemType guessType -> Model problemType guessType -> ( Model problemType guessType, Cmd (Msg problemType guessType) )
update spec msg model =
    case msg of
        ReceiveUpdate roomString ->
            let
                mapRm =
                    roomString
                        |> JD.decodeString (Room.decoder spec.problemDecoder spec.guessDecoder)
                        |> (always << Result.toMaybe)
            in
                ( updateGameRoom mapRm model, Random.generate ReceiveNewProblem spec.problemGenerator )

        ReceiveNewProblem problem ->
            ( updateGameRoom
                (\maybeRoom ->
                    case maybeRoom of
                        Just room ->
                            let
                                oldRound =
                                    room.round

                                newRound =
                                    { oldRound | problem = Just problem }
                            in
                                { room | round = newRound } |> Just

                        Nothing ->
                            Nothing
                )
                model
            , Cmd.none
            )

        Guess guess ->
            let
                _ =
                    Debug.log "guess" guess
            in
                ( model, Cmd.none )

        ChangeRoute route ->
            ( { model | route = route }
            , cmdOnRouteChange route (Just model.route)
            )

        Navigate newUrl ->
            ( model, Navigation.newUrl newUrl )

        _ ->
            ( model, Cmd.none )
