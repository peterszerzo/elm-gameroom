module Gameroom exposing (..)

{-| This is a framework for creating multiplayer guessing games by the boatloads, all within the comfort of Elm. Specify only what is unique to a game, write no logic on the back-end, and have it all wired up and ready to play.

`elm-gameroom` takes care of calling game rounds, generating problems and reconciling scores, as well as talking to either a generic real-time database such as Firebase (JS adapter provided), with have clients sort things out amongst themselves via WebRTC (JavaScript glue code provided).

# The program
@docs program, programAt

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
import Init exposing (init)
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

    port incoming = (JE.Value -> msg) -> Sub msg
    port outgoing = JE.Value -> Cmd msg

    ports = { incoming = incoming, outgoing = outgoing }

Talking to them is best understood with [this simple example](https://github.com/peterszerzo/elm-gameroom/blob/master/src/js/talk-to-ports.js).
-}
type alias Ports msg =
    Ports.Ports msg


{-| Create a fully functional game program from a gamespec and a ports record. The [Spec](/Gameroom-Spec) is the declarative definition of the data structures, logic and view behind your game. [Ports](/Gameroom#Ports) is a record containing two ports defined and wired up by the client. For more details on wiring up ports to a generic backend, see the [JS documentation](/src/js/README.md). Don't worry, it is all razorthin boilerplate.

Notice you don't have to supply any `init`, `update` or `subscriptions` field yourself. All that is taken care of, and you wind up with a working interface that allows you to create game rooms, invite others, and play. Timers, scoreboards etc. all come straight out of the box.
-}
program :
    Spec problem guess
    -> Ports.Ports (Msg problem guess)
    -> Program Never (Model problem guess) (Msg problem guess)
program spec ports =
    Navigation.program (Messages.ChangeRoute << (Router.parse Nothing))
        { init = init Nothing spec ports
        , view = view Nothing spec
        , update = update Nothing spec ports
        , subscriptions = subscriptions spec ports
        }


{-| Same as program, but runs at a base url different from root, e.g. programAt "coolgame" will run on "/coolgame", "/coolgame/new", "/coolgame/tutorial" etc. Useful if you wish to host several games on one page.
-}
programAt :
    String
    -> Spec problem guess
    -> Ports.Ports (Msg problem guess)
    -> Program Never (Model problem guess) (Msg problem guess)
programAt baseSlug spec ports =
    Navigation.program (Messages.ChangeRoute << (Router.parse (Just baseSlug)))
        { init = init (Just baseSlug) spec ports
        , view = view (Just baseSlug) spec
        , update = update (Just baseSlug) spec ports
        , subscriptions = subscriptions spec ports
        }
