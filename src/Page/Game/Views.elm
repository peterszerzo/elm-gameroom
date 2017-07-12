module Page.Game.Views exposing (view)

import Dict
import Window
import Html exposing (Html, div, text, p, h2, ul, li, span, a)
import Html.Attributes exposing (class, style, href)
import Html.Events exposing (onClick)
import Data.Spec as Spec
import Data.Room as Room
import Data.RoundTime as RoundTime
import Page.Game.Messages exposing (Msg(..))
import Page.Game.Models exposing (Model, isHost, getNotificationContent)
import Views.Footer as Footer
import Views.Scoreboard as Scoreboard
import Views.Timer as Timer
import Views.Notification as Notification
import Views.Loader as Loader
import Page.Game.Views.Styles exposing (CssClasses(..), localClass, localClassList)


viewReadyPrompt :
    Spec.DetailedSpec problem guess
    -> Model problem guess
    -> Room.Room problem guess
    -> Html (Msg problem guess)
viewReadyPrompt spec model room =
    div [ localClass [ ReadyPrompt ] ] <|
        [ h2 [] [ text ("Hello, gamer " ++ model.playerId ++ "!") ]
        , p [] [ text ("And welcome to room " ++ model.roomId ++ ".") ]
        ]
            ++ (if isHost model then
                    [ p [] [ text "You are a host for this room. Here are the links to invite them to the game:" ]
                    , ul []
                        (model.room
                            |> Maybe.map .players
                            |> Maybe.map Dict.toList
                            |> Maybe.map
                                (List.filter (\( playerId, _ ) -> model.playerId /= playerId)
                                    >> List.map
                                        ((\( playerId, player ) ->
                                            a
                                                [ localClassList [ ( Link, True ), ( DisabledLink, playerId == model.playerId ) ]
                                                , href
                                                    (spec.basePath
                                                        ++ (if spec.basePath == "/" then
                                                                "rooms/"
                                                            else
                                                                "/rooms/"
                                                           )
                                                        ++ model.roomId
                                                        ++ "/"
                                                        ++ playerId
                                                    )
                                                ]
                                                [ text (playerId ++ "'s game link") ]
                                         )
                                        )
                                )
                            |> Maybe.withDefault []
                        )
                    ]
                else
                    []
               )
            ++ [ p [] [ text "Do let us know when you're ready - the game starts immediately once all players marked themselves as such." ]
               , ul
                    []
                    (room.players
                        |> Dict.toList
                        |> List.map Tuple.second
                        |> List.map
                            (\pl ->
                                li []
                                    [ span
                                        ([ localClassList
                                            [ ( Link, True )
                                            , ( DisabledLink, model.playerId /= pl.id )
                                            ]
                                         ]
                                            ++ (if model.playerId == pl.id then
                                                    [ onClick MarkReady ]
                                                else
                                                    []
                                               )
                                        )
                                        [ text
                                            (if pl.id == model.playerId then
                                                (if pl.isReady then
                                                    "Mark me non-ready"
                                                 else
                                                    "I feel ready"
                                                )
                                             else
                                                (pl.id
                                                    ++ (if pl.isReady then
                                                            " is ready"
                                                        else
                                                            " is prepping"
                                                       )
                                                )
                                            )
                                        ]
                                    ]
                            )
                    )
               ]


viewRoom :
    Spec.DetailedSpec problem guess
    -> Window.Size
    -> Model problem guess
    -> Room.Room problem guess
    -> List (Html (Msg problem guess))
viewRoom spec windowSize model room =
    [ if Room.allPlayersReady room then
        (case room.round of
            Just round ->
                div
                    [ localClass [ GamePlay ] ]
                    [ Html.map Guess
                        (spec.view
                            { windowSize = windowSize
                            , roundTime = RoundTime.timeSinceNewRound model.time
                            , ownGuess = room.players |> Dict.get model.playerId |> Maybe.andThen .guess |> Maybe.map .value
                            , opponentGuesses =
                                room.players
                                    |> Dict.toList
                                    |> List.filterMap
                                        (\( playerId, player ) ->
                                            if playerId /= model.playerId then
                                                player.guess
                                                    |> Maybe.map .value
                                                    |> Maybe.map (\val -> ( playerId, val ))
                                            else
                                                Nothing
                                        )
                            , isRoundOver = RoundTime.timeSinceNewRound model.time > spec.roundDuration
                            }
                            round.problem
                        )
                    ]

            Nothing ->
                div [] [ text "Awaiting game" ]
        )
      else
        viewReadyPrompt spec model room
    , Notification.view (getNotificationContent spec model) Nothing
    , if (Room.allPlayersReady room) then
        Timer.view ((RoundTime.timeSinceNewRound model.time) / spec.roundDuration)
      else
        div [] []
    , Footer.view
        [ room.players
            |> Dict.toList
            |> List.map
                (\( playerId, player ) ->
                    ( player.id, player.score )
                )
            |> Scoreboard.view
        ]
    ]


view :
    Spec.DetailedSpec problem guess
    -> Window.Size
    -> Model problem guess
    -> Html (Msg problem guess)
view spec windowSize model =
    div [ localClass [ Root ] ]
        (case model.room of
            Just room ->
                viewRoom spec windowSize model room

            Nothing ->
                [ div [ localClass [ LoaderContainer ] ] [ Loader.view ] ]
        )
