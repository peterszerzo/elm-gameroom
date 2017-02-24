Elm-Europe 2017 talk draft

# elm-gameroom: make a game in 200 lines

---

## Two years ago on a winter evening in Canada..

I was playing an annoying word game, thinking:

> I should totally make this for the web.

I got around to in two years later. In Elm.

https://lettero.co

---

## So how was it?

Well, client-server logic sharing quickly got tedious.

> There's no way around it, I guess. Someone needs to call the shots and reconcile the score, right?

Or should I run some Elm in Node?

---

## Or maybe my use-case is a little special

It's a guessing game: all players need to be online at all times.

So just designate one of the clients as game host - reconcile and control game from that client.

We can strip the server down to a data store.

---

## Can we abstract this?

### What do we need to describe a game?

* the problem: `"hedgehog"`
* the guess: `1`
* a view as a function of the problem, emitting guesses: `span [ onClick 2 ] [ text "d" ]`
* when is a guess correct:
  `Cool: guess == 0`
  `Better luck next time: guess == 0`
* a collection of possible game problems. Or a random problem generator.

---

### How does this look like in Elm, for Lettero?

* `type alias ProblemType = String`
* `type alias GuessType = Int`
* `view : ProblemType -> Html GuessType`
* `isGuessCorrect : ProblemType -> GuessType -> Bool`
* `problemGenerator : Random.Generator ProblemType`

---

### Anything else?

Gotta persist information between players. So we need some encoders and decoders.

---

### How does this look like?

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

## And then there was refactoring

It's impossible to write (really) bad Elm code.

Or is it?

```elm
modules Models.Player exposing (..)

type alias Player = { ... }

getDummy : String -> Player
```

---

```elm
type alias Model =
  { route : Route
  }

type Route
  = Game GameModel
  | RoomCreator RoomCreatorModel
  | RoomManager RoomManagerModel
  | Tutorial TutorialModel
```

Yup, all components are fully independent, with some mighty strange glue code...

---

```elm
updateGame : Game.Messages.Msg -> Model -> ( Model, Cmd Msg )
updateGame msg model =
    Game.Messages.newPath msg
        |> Maybe.map (\str -> model ! [ Navigation.newUrl str ])
        |> Maybe.withDefault
            (case model.route of
                Router.Game model_ ->
                    Game.Update.update msg model_
                        |> (\( md, cmd ) -> ( { model | route = Router.Game md }, Cmd.map GameMsg cmd ))

                _ ->
                    ( model, Cmd.none )
            )

-- Same for updateRoomCreator, updateRoomManager and updateTutorial

-- Oh, and there's some more wiring on commands and subscriptions

update : -- You don't want to know...
```

And above all, the bits and pieces that make up the `Spec` record above for the game are scattered all over the place.

### Some learning

* With lots of type variables, you get less help from the compiler: `Maybe change your type annotation to be more specific? Maybe the code has a
problem?`.

## Let's make a game!
