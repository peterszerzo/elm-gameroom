module Gameroom exposing (..)

{-| This is an opinionated framework for multiplayer guessing games. It takes care of the boilerplate for calling game rounds, generating problems and reconciling players, allowing the client to specify only the bits unique to each game, and write fully functional frustraing entertainment in just about 200 lines of code.

For some context on how it came to be, head here: https://github.com/peterszerzo/elm-gameroom/blob/master/talk.md.

# The program
@docs program

# Program types
@docs Model, Msg
-}

import Navigation
import Gameroom.Models.Main
import Gameroom.Spec exposing (Spec)
import Gameroom.Ports
import Gameroom.Subscriptions exposing (subscriptions)
import Gameroom.Messages as Messages
import Gameroom.Update exposing (update, cmdOnRouteChange)
import Gameroom.Router as Router
import Gameroom.Views.Main exposing (view)


{-| Use this Msg type to annotate your program.
-}
type alias Msg problem guess =
    Messages.Msg problem guess


{-| Use this Model type to annotate your program.
-}
type alias Model problem guess =
    Gameroom.Models.Main.Model problem guess


{-| Create the game program from a Spec - declarative definition of game rules, data structures - and a record of Ports - defined and wired up by the client. See Gameroom.Spec and Gameroom.Ports documentation for details.
-}
program :
    Spec problem guess
    -> Gameroom.Ports.Ports (Msg problem guess)
    -> Program Never (Model problem guess) (Msg problem guess)
program spec ports =
    Navigation.program (Messages.ChangeRoute << Router.parse)
        { init =
            (\loc ->
                let
                    route =
                        Router.parse loc

                    cmd =
                        cmdOnRouteChange ports route Nothing
                in
                    ( { route = route }, cmd )
            )
        , view = view spec
        , update = update spec ports
        , subscriptions = subscriptions ports
        }
