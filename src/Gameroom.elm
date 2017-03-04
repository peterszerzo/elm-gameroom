module Gameroom exposing (..)

{-| This is an opinionated framework for multiplayer guessing games. It takes care of the boilerplate for calling game rounds, generating problems and reconciling players, allowing the client to specify only the bits unique to each game, and write fully functional frustraing entertainment in just about 200 lines of code.

For some context on how it came to be, head here: https://github.com/peterszerzo/elm-gameroom/blob/master/talk.md.

# The program
@docs program

# Program types
@docs Model, Msg
-}

import Time
import Navigation
import Gameroom.Models.Main
import Gameroom.Spec exposing (Spec)
import Gameroom.Ports
import Gameroom.Messages as Messages
import Gameroom.Update exposing (update, cmdOnRouteChange)
import Gameroom.Router as Router
import Gameroom.Views.Main exposing (view)
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Modules.NewRoom.Messages as NewRoomMessages


{-| Use this Msg type to annotate your program.
-}
type alias Msg problemType guessType =
    Messages.Msg problemType guessType


{-| Use this Model type to annotate your program.
-}
type alias Model problemType guessType =
    Gameroom.Models.Main.Model problemType guessType


{-| Create the game program from a Spec - declarative definition of game rules, data structures - and a record of Ports - defined and wired up by the client. See Gameroom.Spec and Gameroom.Ports documentation for details.
-}
program :
    Spec problemType guessType
    -> Gameroom.Ports.Ports (Msg problemType guessType)
    -> Program Never (Model problemType guessType) (Msg problemType guessType)
program spec config =
    Navigation.program (Messages.ChangeRoute << Router.parse)
        { init =
            (\loc ->
                let
                    route =
                        Router.parse loc

                    cmd =
                        cmdOnRouteChange config route Nothing
                in
                    ( { route = route }, cmd )
            )
        , view = view spec
        , update = update spec config
        , subscriptions =
            (\model ->
                Sub.batch
                    [ config.roomUpdated (\val -> Messages.GameMsgC (GameMessages.ReceiveUpdate val))
                    , case model.route of
                        Router.Game _ ->
                            Time.every (20000 * Time.millisecond) (\time -> Messages.GameMsgC (GameMessages.Tick time))

                        Router.NewRoomRoute _ ->
                            config.roomCreated (\msg -> Messages.NewRoomMsgC (NewRoomMessages.CreateResponse msg))

                        _ ->
                            Sub.none
                    ]
            )
        }
