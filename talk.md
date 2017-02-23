Elm-Europe 2017 talk draft

# Multiplayer guessing game in 200 lines

## One winter evening in Canada..

After a long day volunteering on a farm, I play an annoying word game.

Two years later, I reproduced it in Elm.

https://lettero.co

### My favorite thing about Lettero: no server-side code

Just a generic realtime database, like Firebase or Horizon.

Wait, but who calls the shots and reconciles game rounds?

Convenient use-case: all players need to be online at all times. If any disconnects, stop the show until they reconnect.

So just designate one of the clients as game host - reconcile and control game from that specific client.

### Can we abstract this?

## elm-gameroom

### What do we need to describe a game like this?

* some data structure describing the current game problem `"hedgehog"`
* some data structure describing any player's guess `1`
* a view describing how the screen looks like based on the current problem and the players' guesses (nice-to-have: also react to user input and report back if a guess is made)
* a way to decide if the guess was correct (`1 !== 0`. Too bad..)
* a way to generate random game problems

### How does this look like in Elm, for Lettero?

* `type alias ProblemType = ...`
* `type alias GuessType = ...`
* `view : List GuessType -> ProblemType -> Html GuessType`
* `isGuessCorrect : ProblemType -> GuessType -> Bool`
* `problemGenerator : Random.Generator ProblemType`

### Anything else?

Gotta persist information between players. So we need some encoders and decoders.

### How does this look like?

```elm
type alias Spec problemType guessType =
    { view : ... -> Html guessType
    , isGuessCorrect : problemType -> guessType -> Bool
    , problemGenerator : Random.Generator problemType
    , problemEncoder : problemType -> Encode.Value
    , problemDecoder : Decoder problemType
    , guessEncoder : guessType -> Encode.Value
    , guessDecoder : Decoder guessType
    }
```

## The refactoring story

### State of lettero.co upon completion

It's impossible to write (really) bad Elm code

Or is it?

```elm
modules Models.Player exposing (..)

type alias Player = { ... }

getDummy : String -> Player
```

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

Yup, all components are fully independent, with some mighty strange glue code:

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

* With lots of type variables, you get less help from the compiler: `Maybe there is a problem with your code?`.

```
Failed to compile.

Error in ./src/Main.elm
Module build failed: Error: Compiler process exited with error Compilation failed
-- TYPE MISMATCH ------------------------------ ./src/Gameroom/Models/Result.elm

The argument to this function is causing a mismatch.

22|                                   spec.isGuessCorrect room.round.problem
                                                               ^^^^^^^^^^^^^
This function is expecting the argument to be:

    problemType

But it is:

    Maybe problemType

Hint: Your type annotation uses type variable `problemType` which means any type
of value can flow through. Your code is saying it CANNOT be anything though!
Maybe change your type annotation to be more specific? Maybe the code has a
problem? More at:
<https://github.com/elm-lang/elm-compiler/blob/0.18.0/hints/type-annotations.md>

Detected errors in 1 module.
 @ ./src/index.js 1:10-31
```

## Let's make a game!
