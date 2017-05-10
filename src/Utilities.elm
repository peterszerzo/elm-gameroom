module Utilities exposing (..)

import Regex exposing (..)


trimspaces : String -> String
trimspaces =
    replace All (regex " ") (\_ -> "-")


urlize : String -> String
urlize =
    trimspaces << String.toLower
