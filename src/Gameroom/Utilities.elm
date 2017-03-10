module Gameroom.Utilities exposing (..)

{-| This module contains generic utility methods useful when defining games.

# Random
@docs generatorFromList
-}

import Random


{-| Create a generator from a discrete list of problems. For instance,

    generatorFromList "apples" [ "oranges", "lemons" ] == generator yielding random problems from ["apples", "oranges", "lemons"]

We're making your life a little hard having to break off the first member of your list, but it is necessary to make sure the array we end up working with is non-empty. We'd love to generate a funny word like "perrywinkle" to keep the compiler happy, but remember, problems can be of any shape or form, and elm-gameroom is unaware of what that shape or form is.
-}
generatorFromList : problem -> List problem -> Random.Generator problem
generatorFromList first rest =
    let
        list =
            [ first ] ++ rest
    in
        Random.int 0 (List.length list - 1)
            |> Random.map
                (\i ->
                    list
                        |> List.drop i
                        |> List.head
                        |> Maybe.withDefault first
                )
