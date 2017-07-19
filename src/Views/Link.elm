module Views.Link exposing (view)

import Html exposing (Html, a)
import Html.Events exposing (onClick)
import Messages exposing (Msg(Navigate))


view :
    String
    -> List (Html.Attribute (Msg problem guess))
    -> List (Html (Msg problem guess))
    -> Html (Msg problem guess)
view url attrs children =
    a
        (attrs
            ++ [ onClick (Navigate url)
               ]
        )
        children
