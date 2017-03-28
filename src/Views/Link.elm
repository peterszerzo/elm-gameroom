module Views.Link exposing (view)

import Html exposing (Html, a)
import Html.Events exposing (onClick)
import Messages.Main exposing (Msg(..))


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
