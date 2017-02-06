Elm-Europe 2017 talk draft

# Multiplayer guessing game in 200 lines

DRY multiplayer guessing game. Add game spec and generic realtime backend.

## lettero.co

This is an abstraction from https://lettero.co.

### Custom game, no server-side code

But who calls the shots and reconciles rounds?

Convenient use-case: all players need to be online at all times. If any disconnects, stop the show until they reconnect.

Designate one of the clients as judge - reconcile and control game from that specific client.

## elm-gameroom

https://runelm.io/c/pxy

```elm
game : GameRoom.Game Int
game =
    { view = (\guess -> div [] [ text ("You guessed " ++ (toString guess)) ])
    , guessEncoder = (\guess -> JE.int 0)
    , guessDecoder = (\jdVal -> 0)
    , isGuessCorrect = (\guess -> True)
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
