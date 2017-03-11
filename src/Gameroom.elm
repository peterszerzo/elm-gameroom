module Gameroom exposing (..)

{-| This is an opinionated framework for multiplayer guessing games. It takes care of the boilerplate for calling game rounds, generating problems and reconciling players, allowing the client to specify only the bits unique to each game, and write fully functional frustraing entertainment in just about 200 lines of code.

For some context on how it came to be, head here: https://github.com/peterszerzo/elm-gameroom/blob/master/talk.md.

# The program
@docs program

# Ports
@docs Ports

# Program types
@docs Model, Msg
-}

import Navigation
import Gameroom.Models.Main
import Gameroom.Models.Ports as Ports
import Gameroom.Spec exposing (Spec)
import Gameroom.Subscriptions exposing (subscriptions)
import Gameroom.Messages as Messages
import Gameroom.Update exposing (update, cmdOnRouteChange)
import Gameroom.Router as Router
import Gameroom.Models.Ports as Ports
import Gameroom.Views.Main exposing (view)


{-| Use this Msg type to annotate your program.
-}
type alias Msg problem guess =
    Messages.Msg problem guess


{-| Use this Model type to annotate your program.
-}
type alias Model problem guess =
    Gameroom.Models.Main.Model problem guess


{-| The Ports record contains incoming and outgoing ports necessary for a guessing game. The client is responsible for declaring them, passing them to the game-generator `program` method, and hooking them up with the realtime back-end. Head to the examples in the repo for some simple usage.

Defining them goes like so:

    port incoming = (String -> msg) -> Sub msg
    port outgoing = String -> Cmd msg

    ports = { incoming = incoming, outgoing = outgoing }

Talking to them is best understood with [this simple example](https://github.com/peterszerzo/elm-gameroom/blob/master/src/js/talk-to-ports.js).
-}
type alias Ports msg =
    Ports.Ports msg


{-| Create the game program from a Spec - declarative definition of game rules, data structures - and a record of Ports - defined and wired up by the client. See Gameroom.Spec and Gameroom.Ports documentation for details.
-}
program :
    Spec problem guess
    -> Ports.Ports (Msg problem guess)
    -> Program Never (Model problem guess) (Msg problem guess)
program spec ports =
    Navigation.program (Messages.ChangeRoute << Router.parse)
        { init =
            (\loc ->
                let
                    route =
                        Router.parse loc

                    cmd =
                        cmdOnRouteChange spec ports route Nothing
                in
                    ( { route = route }, cmd )
            )
        , view = view spec
        , update = update spec ports
        , subscriptions = subscriptions spec ports
        }
