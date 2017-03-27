module Gameroom.Views.Link exposing (view)

import Html exposing (Html, header, text, a)
import Html.Events exposing (onClick)
import Gameroom.Messages exposing (Msg(..))


view :
    String
    -> List (Html.Attribute (Msg problemType guessType))
    -> List (Html (Msg problemType guessType))
    -> Html (Msg problemType guessType)
view url attrs children =
    a
        (attrs
            ++ [ onClick (Navigate url)
               ]
        )
        children
