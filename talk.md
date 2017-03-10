Elm-Europe 2017 talk draft

# Multiplayer guessing game in 200 lines

---

## Two years ago on a winter evening in Canada..

I was playing a word game, thinking:

> I should totally make this for the browser.

https://lettero.co

---

## So how was it?

Oh, client-server logic splitting/sharing...

> There's no way around it, I guess.

Or maybe I should run some Elm in Node?

Or can I do better?

---

## The use-case is a little special

All players need to be online at all times.

So we can:
* push game room state to all clients.
* designate one of the clients as a host.
* this host calls the shots and updates the scores.

(beware of race conditions)

=> Generic realtime backend: Firebase, Horizon, or something custom.

=> No more client-server code sharing.

---

## Now that we're comfortable, can we abstract?

### What are the elements that define a game uniquely?

* the `problem = "hedgehog"`
* the `guess = 1`
* a view as a function of the `problem`, emitting `guess`es: `span [ onClick 2 ] [ text "d" ]`
* some way to decide whether a guess is correct:
  `\guess -> guess == 0`
* a random game problem generator.

---

### How does this look like in Elm, for Lettero?

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

### Anything else?

Some encoders and decoders.

```elm
problemEncoder = Json.Encode.string

problemDecoder = Json.Decode.string

guessEncoder = Json.Encode.int

problemDecoder = Json.Decode.int
```

---

### In the abstract..

```elm
type alias Spec problem guess =
    { view : PlayerId -> Players guess -> problem -> Html.Html guess
    , isGuessCorrect : problem -> guess -> Bool
    , problemGenerator : Random.Generator problem
    , problemEncoder : problem -> JE.Value
    , problemDecoder : Decode.Decoder problem
    , guessEncoder : guess -> Encode.Value
    , guessDecoder : Decode.Decoder guess
    }
```

---

### elm-gameroom

```elm
program : Spec problem guess -> Program Never (Model problem guess) (Msg problem guess)
```

---

### Ok, well, not quite that simple

Communicating with the back-end goes through ports.

But you cannot publish a package with ports.
* port name clashes.
* may make projects rely on poorly documented ports.
* semantic versioning cannot be enforced.

---

### The responsible cheater

Library: documents the heck out of how ports should work.
Client: defines and talks to ports, both in Elm and JavaScript.

```elm
type alias Ports msg =
    { unsubscribeFromRoom : String -> Cmd msg
    , subscribeToRoom : String -> Cmd msg
    , createRoom : String -> Cmd msg
    , roomCreated : (String -> msg) -> Sub msg
    , updateRoom : String -> Cmd msg
    , roomUpdated : (String -> msg) -> Sub msg
    , updatePlayer : String -> Cmd msg
    , playerUpdated : (String -> msg) -> Sub msg
    }

program :
  Spec problem guess ->
  Ports (Msg problem guess) ->
  Program Never (Model problem guess) (Msg problem guess)
```

---

## And now that we planned it all..

---

## The refactoring

`Lettero` => `elm-gameroom`

> It's impossible to write (really) bad Elm code. Or is it?

With the refactoring came the pocket learnings...

---

### Cheating Maybe's

```elm
module Models.Room exposing (..)

type alias Room = { ... }

getDummy : String -> Player
```

```elm
view1 model =
    case model.room of
        Just room ->
            view2 model

        Nothing ->
            text "Placeholder"

view2 model =
    model.room
        |> Maybe.withDefault Room.getDummy
        |> ...
```

```elm
view2 model room =
    room
        |> ...
```

> Respect your Maybes #respectyourmaybes.

---

### Impossible states unrepresentable

But really, always..

```elm
type alias Guess = Pending | Made guessValue | Idle
```

But the time elapsed in a certain round is also tracked.

=> `Idle` is derived data.

> Resist the temptation to add explicit derived data just because it is nice to have it explicit.

---

### Autonomous components

In Lettero, gameplay, tutorial and create game room 'components' are fully autonomous.

There is some mighty strange glue code that I do not wish to talk about.

> Embrace codebase socialism.

---

## Let's make a game!
