module Views.Home exposing (..)

import Html exposing (Html, div, text, h1, p)
import Messages exposing (Msg(..))
import Views.Link as Link
import Views.Logo as Logo
import Views.Home.Styles exposing (CssClasses(..), localClass)


view : Html (Msg problem guess)
view =
    div [ localClass [ Root ] ]
        [ div
            [ localClass [ Logo ]
            ]
            [ Logo.view ]
        , h1 [] [ text "elm-gameroom" ]
        , p [] [ text "Prime frustrating entertainment" ]
        , Link.view "/new" [ localClass [ Link ] ] [ text "Play" ]
        , Link.view "/about" [ localClass [ Link ] ] [ text "About" ]
        ]
