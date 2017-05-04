module Views.Notification exposing (..)

import Html exposing (Html, div, p, text)
import Views.Notification.Styles exposing (CssClasses(..), localClass)


view : Maybe String -> Html msg
view body =
    div [ localClass [ Root ] ]
        [ p []
            [ text (body |> Maybe.withDefault "")
            ]
        ]
