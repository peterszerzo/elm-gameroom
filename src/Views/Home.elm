module Views.Home exposing (..)

import Html exposing (Html, div, text, h1)
import Messages exposing (Msg(..))
import Views.Link as Link
import Views.Logo as Logo
import Styles.Shared exposing (CssClasses(Centered, Hero, Link), sharedClass)
import Views.Home.Styles exposing (CssClasses(..), localClass)


view : Html (Msg problem guess)
view =
    div [ sharedClass [ Centered ] ]
        [ div
            [ localClass [ Logo ]
            ]
            [ Logo.view ]
        , h1 [ sharedClass [ Hero ] ] [ text "elm-gameroom" ]
        , Link.view "/tutorial" [ sharedClass [ Link ] ] [ text "Tutorial" ]
        , Link.view "/new" [ sharedClass [ Link ] ] [ text "New room" ]
        ]
