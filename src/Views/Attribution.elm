module Views.Attribution exposing (..)

import Html exposing (Html, div, p, a, span, text)
import Html.Attributes exposing (href)
import Views.Attribution.Styles exposing (CssClasses(..), localClass)
import Views.Logo


view : Html msg
view =
    a [ localClass [ Root ], href "https://elm-gameroom.firebaseapp.com" ]
        [ span [] [ text "Powered by " ]
        , Views.Logo.view
        , span [] [ text " elm-gameroom" ]
        ]
