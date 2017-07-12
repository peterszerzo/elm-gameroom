module Page.NotFound.Views exposing (..)

import Html exposing (Html, div, h2, p, a, text)
import Messages exposing (Msg(..))
import Views.Link
import Page.NotFound.Styles exposing (CssClasses(..), localClass)


view : Html (Msg problem guess)
view =
    div [ localClass [ Root ] ]
        [ h2 [] [ text "Not found.." ]
        , p [] [ text "We all get lost sometimes.." ]
        , Views.Link.view "/" [] [ text "Go to home page" ]
        ]
