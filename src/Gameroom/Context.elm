module Gameroom.Context exposing (..)

{-| When developing elm-gameroom games, the [Spec](/Gameroom-Spec) object requires a view function that controls how the problem should be represented. This function takes a context as a first parameter, which you can use to display additional clues in your game, such as feedback when a guess is made or when the correct guess may be revealed. It also gives you access to the number of repaints that have occurred as well as the size of the window, so you can get super custom and even WebGL-y, if that strikes your fancy.

# The Context type
@docs Context

# Helpers
@docs allGuesses
-}

import Window


{-| The context object, containing the following fields:

* `ownGuess`: the guess made by the current client, if any.
* `windowSize`: the size of the window, as per `elm-lang/window`.
* `animationTicksSinceNewRound`: the number of repaints since the new round started. Useful for custom animations and WebGL.
* `opponentGuesses`: a `( String, guess )` tuple listing any guesses made by opponents.
* `isRoundOver`: states whether the current game round has been decided. At this point, you can reveal the correct answer while the round is in cooldown.
-}
type alias Context guess =
    { ownGuess : Maybe guess
    , windowSize : Window.Size
    , animationTicksSinceNewRound : Int
    , opponentGuesses : List ( String, guess )
    , isRoundOver : Bool
    }


{-| Get a list of all guesses made so far.
-}
allGuesses : Context guess -> List guess
allGuesses ctx =
    (ctx.ownGuess |> Maybe.map (\g -> [ g ]) |> Maybe.withDefault [])
        ++ (ctx.opponentGuesses |> List.map Tuple.second)
