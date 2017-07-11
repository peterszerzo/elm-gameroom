module Gameroom.Utils exposing (..)

{-| This module contains generic utility methods useful when defining games.

# Random
@docs generatorFromList
-}

import Random


{-| Create a generator from a discrete list of problems, the first of which is supplied separately to make sure the list is not empty. For instance,

    generatorFromList "apples" [ "oranges", "lemons" ] == generator yielding random problems from ["apples", "oranges", "lemons"]
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
