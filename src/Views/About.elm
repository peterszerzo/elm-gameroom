module Views.About exposing (..)

import Html exposing (Html, div, h2, p, a, text)
import Html.Attributes exposing (href)
import Messages exposing (Msg(..))
import Gameroom.Spec exposing (Spec)
import Views.Link
import Views.About.Styles exposing (CssClasses(..), localClass)


view : Spec problem guess -> Html (Msg problem guess)
view spec =
    div [ localClass [ Root ] ]
        [ h2 [] [ text ("About " ++ spec.copy.name) ]
        , p [] [ text "This game is powered by a library called elm-gameroom, which makes it easy to create your own multiplayer game with simple, declarative configuration." ]
        , Views.Link.view "/new" [] [ text "Back to the game" ]
        , a [ href "https://github.com/peterszerzo/elm-gameroom" ] [ text "Make your own" ]
        ]
