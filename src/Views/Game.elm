module Views.Game exposing (..)

import Dict
import Html exposing (Html, div, text, p, h2, ul, li, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Gameroom.Spec exposing (Spec)
import Constants as Consts
import Models.Game as Game
import Models.Room as Room
import Messages.Game exposing (Msg(..))
import Views.Styles as Styles
import Views.Footer as Footer
import Views.Scoreboard as Scoreboard
import Views.Timer as Timer


viewReadyPrompt :
    Spec problemType guessType
    -> Game.Game problemType guessType
    -> Room.Room problemType guessType
    -> Html (Msg problemType guessType)
viewReadyPrompt spec model room =
    div [ style Styles.centered ]
        [ h2 [ style Styles.subheroType ] [ text "Ready?" ]
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
                                ([ style
                                    (if model.playerId == pl.id then
                                        Styles.link
                                     else
                                        Styles.disabledLink
                                    )
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


viewRoom : Spec problem guess -> Game.Game problem guess -> Room.Room problem guess -> Html (Msg problem guess)
viewRoom spec model room =
    div []
        [ if Room.allPlayersReady room then
            (case room.round.problem of
                Just problem ->
                    Html.map Guess (spec.view model.playerId room.players problem)

                Nothing ->
                    div [] [ text "Awaiting problem" ]
            )
          else
            viewReadyPrompt spec model room
        , Footer.view
            [ Timer.view (model.roundTime / Consts.roundDuration)
            , room.players
                |> Dict.toList
                |> List.map
                    (\( playerId, player ) ->
                        ( player.id, player.score )
                    )
                |> Scoreboard.view
            ]
        ]


view : Spec problem guess -> Game.Game problem guess -> Html (Msg problem guess)
view spec model =
    case model.room of
        Just room ->
            viewRoom spec model room

        Nothing ->
            div [ style Styles.centered ]
                [ text "Loading" ]
