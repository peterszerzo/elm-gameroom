module Gameroom exposing (..)

{-| This is a framework for creating multiplayer guessing games. It takes care of calling game rounds, generating problems and reconciling players, as well as talking directly to a generic realtime backend. The client gets to specify only the bits unique to each game, and write fully functional frustrating entertainment in just under 200 lines of code.

For some context on how it came to be, head here: https://github.com/peterszerzo/elm-gameroom/blob/master/talk.md.

# The program
@docs program

# Ports
@docs Ports

# Program types
@docs Model, Msg
-}

import Navigation
import Models
import Models.Ports as Ports
import Gameroom.Spec exposing (Spec)
import Subscriptions exposing (subscriptions)
import Messages
import Update exposing (update, cmdOnRouteChange)
import Router as Router
import Models.Ports as Ports
import Views exposing (view)


{-| Use this Msg type to annotate your program.
-}
type alias Msg problem guess =
    Messages.Msg problem guess


{-| Use this Model type to annotate your program.
-}
type alias Model problem guess =
    Models.Model problem guess


{-| The Ports record contains incoming and outgoing ports necessary for a guessing game. The client is responsible for declaring them, passing them to the game-generator `program` method, and hooking them up with the realtime back-end. Head to the examples in the repo for some simple usage.

Defining them goes like so:

    port incoming = (String -> msg) -> Sub msg
    port outgoing = String -> Cmd msg

    ports = { incoming = incoming, outgoing = outgoing }

Talking to them is best understood with [this simple example](https://github.com/peterszerzo/elm-gameroom/blob/master/src/js/talk-to-ports.js).
-}
type alias Ports msg =
    Ports.Ports msg


{-| Create the game program from a `spec` record and a `ports` record. The Spec is the declarative definition of game's rules and view - see `Gameroom.Spec` documentation for details. The `Ports` is a record contains two ports defined and wired up by the client. For more details on wiring up ports to a generic backend, see the [JS documentation](https://github.com/peterszerzo/elm-gameroom/blob/master/src/js/talk-to-ports.js).
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
