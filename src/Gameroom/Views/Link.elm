module Gameroom.Views.Link exposing (view)

import Html exposing (Html, header, text, a)
import Html.Attributes exposing (class, style, href)
import Gameroom.Messages exposing (Msg(..))
import Gameroom.Views.Styles as Styles


view : List (Html.Attribute (Msg problemType guessType)) -> List (Html (Msg problemType guessType)) -> Html (Msg problemType guessType)
view attrs children =
    a (attrs ++ [ style Styles.link ]) children
