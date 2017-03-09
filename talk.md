Elm-Europe 2017 talk draft

# elm-gameroom: multiplayer game in 200 lines

---

## Two years ago on a winter evening in Canada..

I was playing a word game, thinking:

> I should totally make this for the browser.

I got around to it two years later. In Elm.

https://lettero.co

---

## So how was it?

Well, client-server logic sharing quickly got weird and tedious.

> There's no way around it, I guess. Someone needs to call the shots and reconcile the score, right?

Or maybe I should run some Elm in Node?

Can we do better?

---

## The use-case is a little special

It's a guessing game: all players need to be online at all times.

So we can:
* keep track of the entire game state on all clients. Push changes as they happen.
* designate one of the clients as a host.
* if the game round is over based on state on any one client and that client happens to be the host, then reconcile scores and initiate new round.

=> we can strip the server down to generic realtime backend: Firebase, Horizon, or something custom.

=> no more client-server code sharing.

---

## Now that we're comfortable, can we abstract?

### What do we need to describe a game?

* the `word = "hedgehog"`
* the `guess = 1`
* a view as a function of the problem, emitting guesses: `List.indexedMap (\index letter -> span [ onClick index ] [ text letter ]) (String.split "" word)`
* whether a guess is correct:
  `guess == 0` is cool
  but `guess == 0` is a `betterLuckNextTime()`
* a collection of possible game problems. Or a random game problem generator.

---

### How does this look like in Elm, for Lettero?

```elm
type alias ProblemType = String

type alias GuessType = Int

view : ProblemType -> Html GuessType
view =
    List.indexedMap (\index letter -> span [ onClick index ] [ text letter ]) letters

isGuessCorrect : ProblemType -> GuessType -> Bool
isGuessCorrect problem guess =
    guess == 0

problemGenerator : Random.Generator ProblemType
problemGenerator =
  -- Generate a random word from a list of words
```

---

### Anything else?

Gotta persist information between players. So we need some encoders and decoders.

```elm
problemEncoder = Json.Encode.string

problemDecoder = Json.Decode.string

guessEncoder = Json.Encode.int

problemDecoder = Json.Decode.int
```

---

### How does all this look like in the abstract?

```elm
type alias Spec problemType guessType =
    { view : PlayerId -> Players guessType -> problemType -> Html.Html guessType
    , isGuessCorrect : problemType -> guessType -> Bool
    , problemGenerator : Random.Generator problemType
    , problemEncoder : problemType -> JE.Value
    , problemDecoder : JD.Decoder problemType
    , guessEncoder : guessType -> JE.Value
    , guessDecoder : JD.Decoder guessType
    }
```

---

### elm-gameroom

A library that takes in a `Spec` and spits out a program.

```elm
program : Spec pt gt -> Program Never (Model pt gt) (Msg pt gt)
```

---

### Ok, well, not quite that simple

Communicating with the back-end goes through ports.

But you cannot publish a package that defines its own ports, for very good reasons:
* may clash with port names the client defined.
* may make projects rely on poorly documented ports.
* semantic versioning on what goes in and out of ports cannot be enforced.

---

### The responsible cheater

It is the client's responsibility to set up the ports and communicate with them in the 'correct' way.

`elm-gameroom` expects these ports to be passed in by the client.

```elm
type alias Ports msg =
    { unsubscribeFromRoom : String -> Cmd msg
    , subscribeToRoom : String -> Cmd msg
    , updateRoom : String -> Cmd msg
    , roomUpdated : (String -> msg) -> Sub msg
    , createRoom : String -> Cmd msg
    , roomCreated : (String -> msg) -> Sub msg
    }

program : Spec pt gt -> Ports (Msg pt gt) -> Program Never (Model pt gt) (Msg pt gt)
```

---

## And then there was refactoring

It's impossible to write (really) bad Elm code.

Or is it?

---

### Cheating Maybe's

```elm
modules Models.Player exposing (..)

type alias Player = { ... }

getDummy : String -> Player
```

---

### Impossible states representable

```elm
type alias Guess = Pending | Made guessValue | Idle
```

The time elapsed in a certain round is also tracked.

=> `Idle` is derived data

---

### Autonomous components

Gameplay, tutorial and create game room 'components' are fully autonomous, with their own messages, model, update, and even commands and subscriptions.

There is some mighty strange glue code that I do not wish to talk about.

---

## Refactoring or waterfall?

These quirks above made the code so unpleasant that I decided to start with the public API above and just rewrite, copying over bits of Lettero when appropriate.

Good high-level design goes most of the way there. 

---

## Let's make a game!
