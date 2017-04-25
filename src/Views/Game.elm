module Views.Game exposing (..)

import Dict
import Html exposing (Html, div, text, p, h2, ul, li, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Gameroom.Spec exposing (Spec)
import Constants as Consts
import Models.Game as Game
import Models.Room as Room
import Messages exposing (GameMsg(..))
import Styles
import Views.Footer as Footer
import Views.Scoreboard as Scoreboard
import Views.Timer as Timer
import Views.Loader as Loader


{ class, classList } =
    Html.CssHelpers.withNamespace ""


viewReadyPrompt :
    Spec problem guess
    -> Game.Game problem guess
    -> Room.Room problem guess
    -> Html (GameMsg problem guess)
viewReadyPrompt spec model room =
    div [ class [ Styles.Centered ] ]
        [ h2 [ class [ Styles.Subhero ] ] [ text "Ready?" ]
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
                                ([ classList
                                    [ ( Styles.Link, True )
                                    , ( Styles.LinkDisabled, model.playerId /= pl.id )
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


viewRoom :
    Spec problem guess
    -> Game.Game problem guess
    -> Room.Room problem guess
    -> Html (GameMsg problem guess)
viewRoom spec model room =
    div []
        [ if Room.allPlayersReady room then
            (case room.round.problem of
                Just problem ->
                    Html.map Guess (spec.view model.playerId room.players model.ticksSinceNewRound problem)

                Nothing ->
                    div [] [ text "Awaiting problem" ]
            )
          else
            viewReadyPrompt spec model room
        , Footer.view
            [ Timer.view ((model.ticksSinceNewRound |> toFloat) / (Consts.ticksInRound |> toFloat))
            , room.players
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
    case model.room of
        Just room ->
            viewRoom spec model room

        Nothing ->
            div [ class [ Styles.Centered ] ]
                [ Loader.view ]
