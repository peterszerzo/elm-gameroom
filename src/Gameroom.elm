module Gameroom
    exposing
        ( Spec
        , Ports
        , Msg
        , Model
        , basePath
        , name
        , subheading
        , instructions
        , icon
        , program
        , programWith
        )

{-| This is a framework for creating multiplayer guessing games by the boatloads, all within the comfort of Elm. Specify only what is unique to a game, write no logic on the back-end, and have it all wired up and ready to play.

`elm-gameroom` takes care of calling game rounds, generating problems and reconciling scores, as well as talking to either a generic real-time database such as Firebase (JS adapter provided), with have clients sort things out amongst themselves via WebRTC (JavaScript glue code provided).

# The program
@docs Spec, program, programWith

# Ports
@docs Ports

# Options
@docs basePath, name, subheading, instructions, icon

# Program types
@docs Model, Msg
-}

import Navigation
import Models
import Models.Ports as Ports
import Subscriptions exposing (subscriptions)
import Messages
import Update exposing (update, cmdOnRouteChange)
import Router as Router
import Models.Ports as Ports
import Models.Spec exposing (Spec, Setting(..), buildDetailedSpec)
import Init exposing (init)
import Views exposing (view)


{-| Define the unique bits and pieces to your game, all generalized over a type variable representing a `problem`, and one representing a `guess`. It's going to look a little heavy, but it'll make sense very quickly, I promise. Here it goes:

    type alias Spec problem guess =
        { view : Context guess -> problem -> Html.Html guess
        , isGuessCorrect : problem -> guess -> Bool
        , problemGenerator : Random.Generator problem
        , problemEncoder : problem -> Encode.Value
        , problemDecoder : Decode.Decoder problem
        , guessEncoder : guess -> Encode.Value
        , guessDecoder : Decode.Decoder guess
        }

* view: The core of the user interface corresponding to the current game round, excluding all navigation, notifications and the score boards. Emits guesses. The first argument is a view context containing peripheral information such as window size, round time, already recorded guesses etc., and it's [documented on its own](/Gameroom-Context). The second, main argument is the current game problem.
* isGuessCorrect: given a problem and a guess, returns whether the guess is correct.
* problemGenerator: a random generator churning out new problems. If your problems are a simple list, we have a [convenient helper](/Gameroom-Utils#generatorFromList).
-}
type alias Spec problem guess =
    Models.Spec.Spec problem guess


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


{-| If your game doesn't start at the root route, you need to tell the package so the routing is done correctly, e.g. `basePath "/game1"`. This is useful if you want to host multiple games on the same domain, and have them share data stores. This is how the demo site is set up :).

You can omit the leading slash or have an extra trailing slash. However, base paths with inner slashes such as `/games/game1` are currently not supported.
-}
basePath : String -> Setting
basePath url =
    BasePath url


{-| The name of your game, e.g. `name "YouWillSurelyLose"`.
-}
name : String -> Setting
name name_ =
    Name name_


{-| A subheading to go under the name on the home page.
-}
subheading : String -> Setting
subheading subheading_ =
    Subheading subheading_


{-| Instructions displayed in the tutorial section.
-}
instructions : String -> Setting
instructions instructions_ =
    Instructions instructions_


{-| A unicode icon for your game.
-}
icon : String -> Setting
icon icon_ =
    Icon icon_


{-| Create a fully functional game program from a game spec and a ports record. The [Spec](/Gameroom#Spec) is the declarative definition of the data structures, logic and view behind your game. [Ports](/Gameroom#Ports) is a record containing two ports defined and wired up by the client. For more details on wiring up ports to a generic backend, see the [JS documentation](/src/js/README.md). Don't worry, it is all razorthin boilerplate.

Notice you don't have to supply any `init`, `update` or `subscriptions` field yourself. All that is taken care of, and you wind up with a working interface that allows you to create game rooms, invite others, and play. Timers, scoreboards etc. all come straight out of the box.
-}
program :
    Spec problem guess
    -> Ports.Ports (Msg problem guess)
    -> Program Never (Model problem guess) (Msg problem guess)
program =
    programWith []


{-| Program with options. will run on "/coolgame", "/coolgame/new", "/coolgame/tutorial" etc. Useful if you wish to host several games on one page.
-}
programWith :
    List Setting
    -> Spec problem guess
    -> Ports.Ports (Msg problem guess)
    -> Program Never (Model problem guess) (Msg problem guess)
programWith options spec ports =
    let
        detailedSpec =
            buildDetailedSpec options spec
    in
        Navigation.program (Messages.ChangeRoute << (Router.parse detailedSpec.basePath))
            { init = init detailedSpec ports
            , view = view detailedSpec
            , update = update detailedSpec ports
            , subscriptions = subscriptions detailedSpec ports
            }
