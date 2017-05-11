module Views.Notification exposing (..)

import Html exposing (Html, div, p, text)
import Html.Events exposing (onClick)
import Views.Notification.Styles exposing (CssClasses(..), localClass, localClassList)


view : Maybe String -> Maybe msg -> Html msg
view body handleClick =
    div
        [ localClassList
            [ ( Root, True )
            , ( RootActive, body /= Nothing )
            , ( RootWithCloseButton, handleClick /= Nothing )
            ]
        ]
    <|
        [ p []
            [ text (body |> Maybe.withDefault "")
            ]
        ]
            ++ (case handleClick of
                    Just handleClick ->
                        [ div [ localClass [ Close ], onClick handleClick ] [ text "×" ] ]

                    Nothing ->
                        []
               )
