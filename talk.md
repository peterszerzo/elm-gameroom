class: center, middle

### 👋

---

class: middle

## Hello, I'm Peter

I split my time between

* ☕🌧️ Copenhagen
* 🐶👩‍🌾 Bucharest
* 🍕🌃 New York

Prototyping theseed.dk.

---

class: middle

## Games!

---

class: center, middle, hero

# Multiplayer guessing games by the boatloads

### Making elm-gameroom

---

class: middle

## Two years ago on a winter evening in Canada..

I was playing a word game, and it was not going well..

> I totally want to make this for the browser

https://lettero.co

---

class: middle

## And then I was thinking..

I totally want to (try) to make this into a multiplayer game framework.

> Specify only what is unique to a game.

---

class: middle

## The original Lettero

Express back-end, Elm frontend. Oh, client-server logic splitting/sharing...

> There's no way around it, I guess.

Or maybe I should run some Elm in Node?

Or can I do better?

---

name: usecaseisspecial
class: middle

## The use-case is a little special

All players need to be online at all times.

So we can:
* have all clients subscribe to the game room state.
* designate one of them as host.
* have the host call the shots and keep the score.

---

template: usecaseisspecial

=> Generic realtime backend: Firebase, Horizon, or something custom.

=> No more client-server code sharing.

---

class: middle

## Can we abstract?

* the `problem = "hedgehog"`
* the `guess = 1`
* a view as a function of the `problem`, emitting `guess`es: `span [ onClick 2 ] [ text "d" ]`
* some way to decide whether a guess is correct:
  `\guess -> guess == 0`
* a random game problem generator.

---

class: middle

### How does this look like for Lettero?

```elm
type alias Problem = String

type alias Guess = Int

view : Problem -> Html Guess
view =
    List.indexedMap (\index letter -> span [ onClick index ] [ text letter ]) letters

isGuessCorrect : Problem -> Guess -> Bool
isGuessCorrect problem guess =
    guess == 0

problemGenerator : Random.Generator Problem
problemGenerator =
  -- Generate a random word from a list of words
```

---

class: middle

### Anything else?

Some encoders and decoders.

```elm
problemEncoder = Json.Encode.string

problemDecoder = Json.Decode.string

guessEncoder = Json.Encode.int

guessDecoder = Json.Decode.int
```

---

class: middle

### In the abstract..

```elm
type alias Spec problem guess =
    { view : PlayerId -> Players guess -> problem -> Html guess
    , isGuessCorrect : problem -> guess -> Bool
    , problemGenerator : Random.Generator problem
    , problemEncoder : problem -> JE.Value
    , problemDecoder : Decode.Decoder problem
    , guessEncoder : guess -> Encode.Value
    , guessDecoder : Decode.Decoder guess
    }
```

---

class: middle

### elm-gameroom

```elm
program : Spec problem guess -> Program Never (Model problem guess) (Msg problem guess)
```

---

class: middle

### Ok, well, not quite that simple

Communicating with the back-end goes through ports.

But you cannot publish a package with ports.
* port name clashes.
* may make projects rely on poorly documented ports.
* semantic versioning cannot be enforced.

---

class: middle

## Ports: the responsible cheater

Client defines the ports, and passes them as configuration.

```elm
type alias Ports msg =
    { outgoing : String -> Cmd msg
    , incoming : (String -> msg) -> Sub msg
    }

program :
  Spec problem guess ->
  Ports (Msg problem guess) ->
  Program Never (Model problem guess) (Msg problem guess)
```

---

class: middle

## Talking to ports is just boilerplate!

Provide it with the library!

```js
import db from '~/src/js/db/firebase.js'
// or db/webrtc.js
import talkToPorts from '~/src/talk-to-ports.js'
import Elm from './Main.elm'

const elmApp = Elm.Main.fullscreen()
talkToPorts(db(), elmApp.ports)
```

---

class: middle

## db.js

```js
const db = dependencies => {
  return {
    getRoom () {},
    createRoom () {},
    updateRoom () {},
    updatePlayer () {},
    subscribeToRoom () {},
    unsubscribeFromRoom () {}
  }
}
```

---

class: middle

## And now that we planned it all..

---

class: middle

## The refactoring

`Lettero` => `elm-gameroom`

> It's impossible to write (really) bad Elm code. Or is it?

---

class: middle

### Cheating Maybe's

```elm
module Models.Room exposing (..)

type alias Room = { ... }

getDummy : String -> Player
```

> Respect your Maybes #respectyourmaybes.

---

class: middle

### Impossible states unrepresentable

But really, always..

```elm
type alias Guess
    = Pending
    | Made guess
    | Idle
```

But the time elapsed in a certain round is also tracked.

=> `Idle` is derived data.

> Resist the temptation to add explicit derived data just because it is nice to have it explicit.

---

class: middle

### Autonomous components

In Lettero, gameplay, tutorial and create game room 'components' are fully autonomous.

There is some mighty strange glue code that I do not wish to talk about.

---

class: middle

## Let's play games!

http://eg1.surge.sh

http://eg2.surge.sh

http://eg3.surge.sh
