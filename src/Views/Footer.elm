module Views.Footer exposing (view)

import Html exposing (Html, div, footer)
import Views.Footer.Styles exposing (CssClasses(..), localClass)


view : List (Html msg) -> Html msg
view children =
    div [ localClass [ Root ] ] children
