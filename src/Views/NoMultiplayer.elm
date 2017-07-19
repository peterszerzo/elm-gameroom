module Views.NoMultiplayer exposing (view)

import Html exposing (Html, div, h1, p, text)
import Views.NoMultiplayer.Styles exposing (CssClasses(..), localClass)


view : Html msg
view =
    div [ localClass [ Root ] ]
        [ h1 [] [ text "Multiplayer not yet working" ]
        , p [] [ text "You need to do some extra setup work for multiplayer to work on this game. Have a look at the elm-gameroom docs for instructions on how to proceed." ]
        ]
