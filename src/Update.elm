module Update exposing (..)

import Navigation
import Random
import Commands as Commands
import Messages exposing (..)
import Models.Room as Room
import Models.Main exposing (Model)
import Gameroom.Spec exposing (Spec)
import Models.Ports exposing (Ports)
import Router as Router
import Models.IncomingMessage as InMsg
import Models.Game as Game
import Models.NewRoom as NewRoom
import Models.Result as Result
import Json.Encode as JE


cmdOnRouteChange :
    Spec problem guess
    -> Ports (Msg problem guess)
    -> Router.Route problem guess
    -> Maybe (Router.Route problem guess)
    -> Cmd (Msg problem guess)
cmdOnRouteChange spec ports route prevRoute =
    case route of
        Router.Game game ->
            Commands.SubscribeToRoom game.roomId
                |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                |> JE.encode 0
                |> ports.outgoing

        _ ->
            prevRoute
                |> Maybe.andThen
                    (\rt ->
                        case rt of
                            Router.Game game ->
                                Commands.UnsubscribeFromRoom game.roomId
                                    |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                                    |> JE.encode 0
                                    |> ports.outgoing
                                    |> Just

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault Cmd.none


saveCmd :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> Game.Game problem guess
    -> Cmd (Messages.Msg problem guess)
saveCmd spec ports model =
    model.room
        |> Maybe.map (Commands.UpdateRoom >> (Commands.commandEncoder spec.problemEncoder spec.guessEncoder) >> JE.encode 0 >> ports.outgoing)
        |> Maybe.withDefault Cmd.none


updateGame :
    Spec problem guess
    -> Ports (Messages.Msg problem guess)
    -> GameMsg problem guess
    -> Game.Game problem guess
    -> ( Game.Game problem guess, Cmd (Messages.Msg problem guess) )
updateGame spec ports msg model =
    case msg of
        ReceiveUpdate room ->
            let
                result =
                    Result.get spec room

                newProblemCmd =
                    if (room.host == model.playerId) then
                        (Random.generate (\pb -> Messages.GameMsg (ReceiveNewProblem pb)) spec.problemGenerator)
                    else
                        Cmd.none

                ( newRoom, cmd ) =
                    case result of
                        Result.Pending ->
                            ( room
                            , if room.round.problem == Nothing then
                                newProblemCmd
                              else
                                Cmd.none
                            )

                        Result.Winner winnerId ->
                            ( if room.host == model.playerId then
                                Room.setNewRound (Just winnerId) room
                              else
                                room
                            , newProblemCmd
                            )

                        Result.Tie ->
                            ( if room.host == model.playerId then
                                Room.setNewRound Nothing room
                              else
                                room
                            , newProblemCmd
                            )
            in
                ( { model
                    | room =
                        Just newRoom
                  }
                , cmd
                )

        ReceiveNewProblem problem ->
            let
                newRoom =
                    model.room
                        |> Maybe.map
                            (\rm ->
                                let
                                    oldRound =
                                        rm.round

                                    newRound =
                                        { oldRound | problem = Just problem }
                                in
                                    { rm | round = newRound }
                            )

                newModel =
                    { model | room = newRoom }

                cmd =
                    saveCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        Guess guess ->
            let
                newModel =
                    { model
                        | room =
                            model.room
                                |> Maybe.map
                                    (Room.updatePlayer
                                        (\pl ->
                                            { pl
                                                | guess = Just { value = guess, madeAt = model.ticksSinceNewRound }
                                            }
                                        )
                                        model.playerId
                                    )
                    }

                cmd =
                    saveCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        MarkReady ->
            let
                newRoom =
                    model.room
                        |> Maybe.map
                            (Room.updatePlayer (\pl -> { pl | isReady = True }) model.playerId)

                newModel =
                    { model | room = newRoom }

                cmd =
                    saveCmd spec ports newModel
            in
                ( newModel
                , cmd
                )

        Tick time ->
            ( { model
                | ticksSinceNewRound =
                    model.ticksSinceNewRound + 1
              }
            , Cmd.none
            )


updateNewRoom : NewRoomMsg -> NewRoom.NewRoom -> ( NewRoom.NewRoom, Bool )
updateNewRoom msg model =
    case msg of
        ChangeRoomId newRoomId ->
            ( { model | roomId = newRoomId }, False )

        ChangePlayerId index value ->
            ( { model
                | playerIds =
                    List.indexedMap
                        (\index_ oldValue ->
                            if index_ == index then
                                value
                            else
                                oldValue
                        )
                        model.playerIds
              }
            , False
            )

        AddPlayer ->
            ( { model | playerIds = model.playerIds ++ [ "" ] }, False )

        RemovePlayer index ->
            ( { model | playerIds = (List.take index model.playerIds) ++ (List.drop (index + 1) model.playerIds) }, False )

        CreateRequest ->
            ( { model | status = NewRoom.Pending }, True )

        CreateResponse response ->
            ( { model | status = NewRoom.Success }, False )


update :
    Spec problem guess
    -> Ports (Msg problem guess)
    -> Msg problem guess
    -> Model problem guess
    -> ( Model problem guess, Cmd (Msg problem guess) )
update spec ports msg model =
    case ( model.route, msg ) of
        ( _, Navigate newUrl ) ->
            ( model, Navigation.newUrl newUrl )

        ( oldRoute, ChangeRoute route ) ->
            ( { model | route = route }
            , cmdOnRouteChange spec ports route (Just oldRoute)
            )

        ( Router.Game game, GameMsg gameMsg ) ->
            let
                ( newGame, cmd ) =
                    updateGame spec ports gameMsg game
            in
                ( { model | route = Router.Game newGame }
                , cmd
                )

        ( Router.NewRoom newRoom, NewRoomMsg newRoomMsg ) ->
            let
                ( newNewRoom, sendSaveCommand ) =
                    (updateNewRoom newRoomMsg newRoom)
            in
                ( { model | route = Router.NewRoom newNewRoom }
                , if sendSaveCommand then
                    Room.create newRoom.roomId newRoom.playerIds
                        |> Commands.CreateRoom
                        |> Commands.commandEncoder spec.problemEncoder spec.guessEncoder
                        |> JE.encode 0
                        |> ports.outgoing
                  else
                    Cmd.none
                )

        ( Router.NewRoom newRoom, IncomingSubscription (InMsg.RoomCreated room) ) ->
            ( { model
                | route =
                    updateNewRoom (CreateResponse "") newRoom
                        |> Tuple.first
                        |> Router.NewRoom
              }
            , Cmd.none
            )

        ( Router.Game game, IncomingSubscription (InMsg.RoomUpdated room) ) ->
            let
                ( newGame, cmd ) =
                    updateGame spec ports (ReceiveUpdate room) game
            in
                ( { model | route = Router.Game newGame }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )
