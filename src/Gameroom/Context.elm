module Gameroom.Context exposing (..)

{-| When developing elm-gameroom games, the [Spec](/Gameroom-Spec) object requires a view function that controls how the problem should be represented. This function takes a context as a first parameter, which you can use to display additional clues in your game, such as feedback when a guess is made or when the correct guess may be revealed. It also gives you access the current round's timer so you can get all animated and even WebGL-y, if that strikes your fancy.

# The Context type
@docs Context

# Helpers
@docs allGuesses
-}

import Window
import Time


{-| The context object, containing the following fields:

* `windowSize`: the size of the window, as per `elm-lang/window`.
* `roundTime`: time since the current round started.
* `ownGuess`: the guess made by the current client, if any.
* `opponentGuesses`: a `( String, guess )` tuple listing any guesses made by opponents.
* `isRoundOver`: states whether the current game round has been decided. At this point, you can reveal the correct answer while the round is in cooldown.
-}
type alias Context guess =
    { windowSize : Window.Size
    , roundTime : Time.Time
    , ownGuess : Maybe guess
    , opponentGuesses : List ( String, guess )
    , isRoundOver : Bool
    }


{-| Get a list of all guesses made so far.
-}
allGuesses : Context guess -> List guess
allGuesses ctx =
    (ctx.ownGuess |> Maybe.map (\g -> [ g ]) |> Maybe.withDefault [])
        ++ (ctx.opponentGuesses |> List.map Tuple.second)
