module Views.Home exposing (..)

import Html exposing (Html, div, text, h1)
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
        , h1 [ localClass [ Title ] ] [ text "elm-gameroom" ]
        , Link.view "/tutorial" [ localClass [ Link ] ] [ text "Tutorial" ]
        , Link.view "/new" [ localClass [ Link ] ] [ text "New room" ]
        ]
