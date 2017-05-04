module Views.Notification exposing (..)

import Html exposing (Html, div, p, text)
import Views.Notification.Styles exposing (CssClasses(..), localClassList)


view : Maybe String -> Html msg
view body =
    div [ localClassList [ ( Root, True ), ( RootActive, body /= Nothing ) ] ]
        [ p []
            [ text (body |> Maybe.withDefault "")
            ]
        ]
