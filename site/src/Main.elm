module Main exposing (..)

import Html exposing (Html, div, h1, p, a, text)
import Html.Attributes exposing (class, href)
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)


games : List String
games =
    [ "lettero"
    , "counterclockwooze"
    , "spacecraterball"
    , "the-capitalist"
    , "fast-and-moebius"
    ]


main : Html msg
main =
    div [ class "elm-gameroom-home" ] <|
        [ svg [] [ use [ xlinkHref "#logo" ] [] ]
        , h1 [] [ text "Play elm-gamerooms" ]
        , p [] [ text "Hey, thanks for stopping by. Here are some playables for you and your friends:" ]
        ]
            ++ (List.map
                    (\game ->
                        a
                            [ class "elm-gameroom-home-link"
                            , href ("/" ++ game)
                            ]
                            [ text game ]
                    )
                    games
               )
            ++ [ p []
                    [ text "This is a demo for the "
                    , a
                        [ class "elm-gameroom-home-simple-link"
                        , href "http://package.elm-lang.org/packages/peterszerzo/elm-gameroom/latest"
                        ]
                        [ text "elm-gameroom" ]
                    , text " project."
                    ]
               ]
