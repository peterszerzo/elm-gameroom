module Views.About exposing (..)

import Html exposing (Html, div, h2, p, a, text)
import Messages exposing (Msg(..))
import Views.Link
import Views.About.Styles exposing (CssClasses(..), localClass)


view : Html (Msg problem guess)
view =
    div [ localClass [ Root ] ]
        [ h2 [] [ text "About elm-gameroom" ]
        , p [] [ text "A multiplayer game framework" ]
        , Views.Link.view "/" [] [ text "Go play" ]
        ]
