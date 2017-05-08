module Gameroom exposing (..)

{-| This is a framework for creating multiplayer guessing games by the boatloads, all within the comfort of Elm. Specify only what is unique to a game, write no logic on the back-end, and have it all wired up and ready to play.

`elm-gameroom` takes care of calling game rounds, generating problems and reconciling scores, as well as talking to either a generic real-time database such as Firebase (JS adapter provided), with have clients sort things out amongst themselves via WebRTC (JavaScript glue code provided).

# The program
@docs program

# Ports
@docs Ports

# Program types
@docs Model, Msg
-}

import Task
import Navigation
import Window
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


{-| Create a fully functional game program from a gamespec and a ports record. The `spec` is the declarative definition of the data structures, logic and view behind your game - see `Gameroom.Spec` documentation for details. `ports` is a record containing two ports defined and wired up by the client. For more details on wiring up ports to a generic backend, see the [JS documentation](/src/js/README.md). Don't worry, it is all razorthin boilerplate.

Notice you don't have to supply any `init`, `update` or `subscriptions` field yourself. All that is taken care of, and you wind up with a working interface that allows you to create game rooms, invite others, and play. Timers, scoreboards etc. all come straight out of the box.
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
                        Cmd.batch
                            [ cmdOnRouteChange spec ports route Nothing
                            , Window.size |> Task.perform Messages.Resize
                            ]
                in
                    ( { route = route
                      , windowSize = Window.Size 0 0
                      }
                    , cmd
                    )
            )
        , view = view spec
        , update = update spec ports
        , subscriptions = subscriptions spec ports
        }
