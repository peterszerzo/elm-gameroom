# 🏓 elm-gameroom

This is a framework for creating multiplayer guessing games by the boatloads, all within the comfort of Elm. Specify only what is unique to each game, write no logic on the back-end, and have it all wired up and ready to play.

`elm-gameroom` takes care of calling game rounds, generating problems and reconciling scores, all the while talking to either a generic real-time database such as Firebase (adapter provided), or have clients sort things out amongst themselves via WebRTC (JavaScript glue code provided).

For some context, see [this talk](https://www.youtube.com/watch?v=sBCz6atTRZk).

## Running the examples

You can try some games made with the framework by playing in two tabs of the same browser - and this will be tremendously useful as you write your own games later on.

To do that, install elm-live: `npm i -g elm-live`. Then run the following command: `bin/example.sh $NAME`, where `$NAME` is a folder name within `./examples`, either `counterclockwooze`, `lettero`, `spacecraterball` or `the-capitalist`.

## Making your own game

To create a simple trivia game, all you need is yay'much (head to the [The Capitalist](/examples/the-capitalist/Main.elm) for a version that is a bit longer and broken down):

```elm
module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Json.Decode as Decode
import Gameroom exposing (..)

-- The problem is record containing
-- a question, possible answers
-- and the index of the correct answer.
type alias Problem =
  { question : String
  , answer : List String
  , correct : Int
  }

-- The guess is an integer holding the index of the correct answer
type alias Guess = Int

-- The main program uses the `game` method, which takes a spec object.
main =
  game
    { view =
      -- Takes a view context and a problem
      -- returns Html that emits raw guesses.
        (\context problem ->
            div
              []
              [ h1 [] [ text problem.question ]
              , ul []
                <| List.indexedMap
                    (\index answer ->
                        li
                          --Cclicks on an answer
                          -- emit raw guesses.
                          [ onClick index
                          ]
                          [ text answer
                          ]
                    )
                    problem.answers
              ]
        )
    , evaluate =
        -- Correct guess evaluates to 100, an incorrect one to 0.
        (\problem guess ->
          if guess == problem.correct then 100 else 0
        )
    , problemGenerator =
        generatorFromList
          -- Default problem
          { question = "Which one is not a taste?"
          , answers = [ "salty", "sour", "notebook" ],
          , correct = 2
          }
          [ -- A list of additional problems.
            -- `generatorFromList` will generate randomly
            -- from this list in each round.
          ]
    -- Some encoders and decoders,
    -- required to transfer data between machines
    -- in multiplayer mode.
    , guessEncoder = Encode.string
    , guessDecoder = Decode.string
    , problemEncoder =
        (\pb ->
            Encode.object
                [ ( "question", Encode.string pb.question )
                , ( "answers",
                      List.map Encode.string pb.answers
                        |> Encode.list
                  )
                , ( "correct", Encode.int pb.correct )
                ]
        )
    , problemDecoder =
        Decode.map3 Problem
            (Decode.field "question" Decode.string)
            (Decode.field "answers" (Decode.list Decode.string))
            (Decode.field "correct" Decode.int)
    }
```

And there you have it - the barebones of your game are defined. There are a couple of steps to take until this becomes playable in multiplayer, but this already renders the tutorial section, so you can get a feel for how your game would play.

### Multiplayer functionality

In order to set up communication between machines, the data needs to go from the Elm app to the outside world. In order to keep the back-end generic, this is done through ports. Compared to the example above, the following modifications are needed:

```elm
port outgoing : Encode.Value -> Cmd msg

port incoming : (Encode.Value -> msg) -> Sub msg

main =
  gameWith
    [ responsiblePorts { incoming = incoming, outgoing = outgoing } ]
    { -- spec object from before
    }
```

Instead of `game`, we now use `gameWith`, which allows a list of settings to be passed to the game program constructor. The first and most important such setting is `responsiblePorts`, which expects a record of incoming and outgoing ports.

We still need to wire up these ports (described right below), but once we do, the game is deployable and playable with any number of players. And it's just boilerplate, I promise :).

### The JavaScript

Under `./src/js` in this repo, you'll find two types of JavaScript files: `db/*.js` and `talk-to-ports.js`. The `db` files are different implementations of the same promise-based API that the client can use to subscribe to a room, send updates to both players and the whole game room, etc. This you can implement yourself for your choice of datastore, or you can use the implementations we provide for `Firebase`, `WebRTC` (Android phones in luck) and `localStorage` (this one assumes that you're in the same browser, so you can test the games you're making in multiplayer). `talk-to-ports.js` wires things up between this database API and the ports we just defined, like so:

```html
<script src="/elm.js"></script>
<!--
Either grab the files from the elm-stuff directory
(you need to figure out the ~ part of the path exactly),
or copy/require the files in whichever way you prefer.
-->
<script src="~/elm-gameroom/src/js/db/local-storage.js"></script>
<script src="~/elm-gameroom/src/js/talk-to-ports.js"></script>
<script>
  var app = Elm.Main.embed(document.getElementById('Root'))
  talkToPorts(db(), app.ports)
</script>
```

And there you have it, the game is fully functional in multiplayer!

### Customization

Lots more customization options are available:

```elm
main =
  gameWith
    [ name "MyCoolGame"
    , roundDuration (10 * Time.second)
    , cooldownDuration (4 * Time.second)
    , clearWinner 100
    , noPeripheralUi
    ]
    { -- spec object from before
    }
```

This produces a game with a custom name, custom round duration, custom cooldown duration between rounds, a clear winner at evaluation 100 (meaning no player can win unless their guess evaluates to exactly 100), and disable the peripheral ui - the score board, timer and winner notifications - so you can build those yourself in whichever design you prefer.

## But how does it work?

`elm-gameroom` aims to keep as much logic and responsibility on the client, so that new games can be set up easily. This involves a fair bit of reconciliation, juggling around race conditions etc., but I'll just start with the gist:

When a client creates a game room, it becomes the room's host, meaning that it will run decisive game logic such as updating scores and generating game problems in its browser. It then pushes updates to wherever the game state lives, whether it's a Firebase datastore or its very own memory. The other clients subscribe to this datastore, and only send their individual guesses to it.

Working this way allows most of the logic to live in Elm, and keep outside code as thin as possible.

## Long story short

`elm-gameroom` aims to make it easy for you to make games, so you can make loads of them and focus on what's interesting. Please let me know what you make, and what I can do to make the process nicer for you :).
