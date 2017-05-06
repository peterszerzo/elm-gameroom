# 🏓 elm-gameroom

This is a framework for creating multiplayer guessing games by the boatloads, all within the comfort of Elm. Specify only what is unique to a game, write no logic on the back-end, and have it all wired up and ready to play.

`elm-gameroom` takes care of calling game rounds, generating problems and reconciling scores, all the while talking to either a generic real-time database such as Firebase (adapter provided), with have clients sort things out amongst themselves via WebRTC (JavaScript glue code provided).

## Running the examples

You can try some games made with the framework by playing in two tabs of the same browser - and this will be tremendously useful as you write your own games later on.

To do that, install elm-live: `npm i -g elm-live`.

Then run the following command: `bin/run-example.sh $NAME`, where `$NAME` is a folder name within `./examples`, either `spinning-shapes`, `lettero` or `capitals`.

## How does it work?

`elm-gameroom` aims to keep as much logic and responsibility on the client, so that new projects can be set up easily. This involves a fair bit of reconciliation, juggling around race conditions etc., but I'll just start with the gist:

When a client creates a game room, it becomes the room's host, meaning that it will run decisive game logic such as updating scores and generating game problems in its browser. It then pushes updates to wherever the game state lives, whether it's a Firebase datastore or its very own memory. The other clients subscribe to this datastore, and only send their individual guesses to it.

Working this way allows most of the logic to live in Elm, and keep outside code as thin as possible.

## Finally, making your own game

Have a look at this Elm bit:

```elm
module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Gameroom exposing (program, Model, Msg, Ports)
import Gameroom.Spec exposing (Spec)


type alias Problem = String


type alias Guess = String


spec : Spec Problem Guess
spec =
    { view =
        (\playerId players _ problem ->
            div
                []
                [ span [ onClick "yes" ] []
                , span [ onClick "no" ] []
                ]
        )
    , isGuessCorrect = (\problem guess -> (guess == "yes"))
    , problemGenerator =
        generatorFromList "Do you like games?"
            [ "Games, ey?"
            , "Are silly games what you're all about?"
            ]
    , guessEncoder = JE.string
    , guessDecoder = JD.string
    , problemEncoder = JE.string
    , problemDecoder = JD.string
    }


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }


main = program spec ports
```

Here's what is happening here:

* we set up some data structures representing the game problem - in this case a question - and a possible guess - in this case an answer to that question.
* some HTML is rendered, and it emits raw guesses, either `yes` or `no`.
* `yes` is the correct guess.
* we have a list of problems as well as a default problem, and we use a utility function to transform that into a random problem generator.
* we give it some encoders and decoders for problems and guesses, so that data can be stored outside of Elm, and sent off to other players.
* we define some ports, and assemble them into a record.
* we give all this stuff to the `program` method, which makes it into a program.

Doing all this, we get an interface in which we can create game rooms, and play against each other. We still need to wire up these ports, but I promise it will be simple. Read along :).

### The JavaScript

Under `./src/js` in this repo, you'll find two types of JavaScript files: `db.js` and `talk-to-ports.js`. The db files are different implementations of the same promise-based API that the client can use to subscribe to a room, send updates to both players and the whole game room, etc. This you can implement yourself for your choice of datastore, or you can use the implementations we provide for `Firebase`, `WebRTC` (Android phones in luck) and `localStorage` (this one assumes that you're in the same browser, so you can test the games you're making). `talk-to-ports.js` wires things up between this database API and the ports we just defined, like so:

```html
<script src="/elm.js"></script>
<script src="/db.js"></script>
<script src="/talk-to-ports.js"></script>
<script>
  var app = Elm.Main.embed(document.getElementById('Root'))
  talkToPorts(db(), app.ports)
</script>
```

## Long story short

`elm-gameroom` aims to make it easy for you to make games, so you can make loads of them and focus on what's interesting. Please let me know what you make, and what I can do to make the process better for you :).
