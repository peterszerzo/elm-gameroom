module Views.Game exposing (..)

import Dict
import Html exposing (Html, div, text, p, h2, ul, li, span, a)
import Html.Attributes exposing (class, style, href)
import Html.Events exposing (onClick)
import Gameroom.Spec exposing (Spec)
import Constants
import Models.Game as Game
import Models.Room as Room
import Messages exposing (GameMsg(..))
import Views.Footer as Footer
import Views.Scoreboard as Scoreboard
import Views.Timer as Timer
import Views.Notification as Notification
import Views.Loader as Loader
import Views.Game.Styles exposing (CssClasses(..), localClass, localClassList)


viewReadyPrompt :
    Spec problem guess
    -> Game.Game problem guess
    -> Room.Room problem guess
    -> Html (GameMsg problem guess)
viewReadyPrompt spec model room =
    div [ localClass [ ReadyPrompt ] ] <|
        [ h2 [] [ text ("Welcome to room " ++ model.roomId) ]
        , p [] [ text "Mark yourself ready:" ]
        , ul
            [ style
                [ ( "list-style", "none" )
                , ( "padding", "0" )
                , ( "margin", "0" )
                ]
            ]
            (room.players
                |> Dict.toList
                |> List.map Tuple.second
                |> List.map
                    (\pl ->
                        li [ style [ ( "display", "inline-block" ) ] ]
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
                                    (pl.id
                                        ++ (if pl.isReady then
                                                " ✓"
                                            else
                                                " .."
                                           )
                                    )
                                ]
                            ]
                    )
            )
        ]
            ++ (if Game.isHost model then
                    [ p [] [ text "Share with your opponents:" ]
                    , ul []
                        (model.room
                            |> Maybe.map .players
                            |> Maybe.map Dict.toList
                            |> Maybe.map
                                (List.map
                                    ((\( playerId, player ) ->
                                        a
                                            [ localClass [ Link ]
                                            , href ("/rooms/" ++ model.roomId ++ "/" ++ playerId)
                                            ]
                                            [ text playerId ]
                                     )
                                    )
                                )
                            |> Maybe.withDefault []
                        )
                    ]
                else
                    []
               )


viewRoom :
    Spec problem guess
    -> Game.Game problem guess
    -> Room.Room problem guess
    -> List (Html (GameMsg problem guess))
viewRoom spec model room =
    [ if Room.allPlayersReady room then
        (case room.round of
            Just round ->
                div
                    [ localClassList
                        [ ( GamePlay, True )
                        , ( GamePlayInCooldown, model.ticksSinceNewRound > Constants.ticksInRound )
                        ]
                    ]
                    [ Html.map Guess (spec.view model.playerId room.players model.animationTicksSinceNewRound round.problem)
                    ]

            Nothing ->
                div [] [ text "Awaiting game" ]
        )
      else
        viewReadyPrompt spec model room
    , Notification.view (Game.getNotificationContent spec model)
    , if (Room.allPlayersReady room) then
        Timer.view ((model.ticksSinceNewRound |> toFloat) / (Constants.ticksInRound |> toFloat))
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
    Spec problem guess
    -> Game.Game problem guess
    -> Html (GameMsg problem guess)
view spec model =
    div [ localClass [ Root ] ]
        (case model.room of
            Just room ->
                viewRoom spec model room

            Nothing ->
                [ Loader.view ]
        )
