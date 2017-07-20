module Utils exposing (trimspaces, urlize, template)

import Regex exposing (..)


trimspaces : String -> String
trimspaces =
    replace All (regex " ") (\_ -> "-")


urlize : String -> String
urlize =
    trimspaces << String.toLower


template : String -> String -> String
template templ value =
    replace
        All
        ("${}" |> escape |> regex)
        (\_ -> value)
        templ
