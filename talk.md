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

* some data structure describing the current game problem `"insurance"`
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

### Can we generalize?

```elm
type alias Spec problemType guessType =
    { view : ... -> Html.Html guessType
    , isGuessCorrect : problemType -> guessType -> Bool
    , problemGenerator : Random.Generator problemType
    , problemEncoder : Maybe problemType -> JE.Value
    , problemDecoder : JD.Decoder (Maybe problemType)
    , guessEncoder : guessType -> JE.Value
    , guessDecoder : JD.Decoder guessType
    }
```

## The refactoring story

### State of lettero.co upon completion

It's impossible to write (really) bad Elm code

Or is it?

(as in at the point my friends were already having fun with it)

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

Yup, all components are fully independent, with some strange glue code:

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

updateRoomCreator : RoomCreator.Messages.Msg -> Model -> ( Model, Cmd Msg )
updateRoomManager : RoomManager.Messages.Msg -> Model -> ( Model, Cmd Msg )
updateTutorial : Tutorial.Messages.Msg -> Model -> ( Model, Cmd Msg )

update : -- You don't want to know...
```

And above all, the bits and pieces that make up the `Spec` record for the game are buried into everything.

### How to go from this to the `elm-gameroom` sketched out above?

* create the spine
* move models
* move views
* move update (this is the hard one)

### How to make hard moves?

Changing code:

`Make your top-level change and follow the compiler down to the details.`

Migrating code:

1. Try dumping stuff over and follow the compiler to make it fit.
2. If not done in 10 minutes, stash and dump a smaller chunk.
3. If breaking up is not an option, well, devise a case-specific strategy.

## Did it work?

Yes. `elm-gameroom` is powering 10 games across the conference.
