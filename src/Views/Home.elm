module Views.Home exposing (..)

import Html exposing (Html, div, text, h1, p)
import Messages exposing (Msg(..))
import Gameroom.Spec exposing (Spec)
import Views.Link as Link
import Views.Home.Styles exposing (CssClasses(..), localClass)


view : Spec problem guess -> Html (Msg problem guess)
view spec =
    div [ localClass [ Root ] ]
        [ div [ localClass [ Logo ] ] [ text spec.copy.icon ]
        , h1 [] [ text spec.copy.name ]
        , p [ localClass [ Subheading ] ] [ text spec.copy.subheading ]
        , div [ localClass [ Nav ] ]
            [ Link.view "/new" [ localClass [ Link ] ] [ text "Play" ]
            , Link.view "/tutorial" [ localClass [ Link ] ] [ text "Tutorial" ]
            , Link.view "/about" [ localClass [ Link ] ] [ text "About" ]
            ]
        ]
