module Page.Home.Views exposing (view)

import Html exposing (Html, div, text, h1, p)
import Messages exposing (Msg(..))
import Data.Spec as Spec
import Views.Link as Link
import Page.Home.Views.Styles exposing (CssClasses(..), localClass)


view : Spec.DetailedSpec problem guess -> Html (Msg problem guess)
view spec =
    div [ localClass [ Root ] ]
        [ div [ localClass [ Logo ] ] [ text spec.icon ]
        , h1 [] [ text spec.name ]
        , p [ localClass [ Subheading ] ] [ text spec.subheading ]
        , div [ localClass [ Nav ] ]
            [ Link.view "/tutorial" [ localClass [ Link ] ] [ text "Try" ]
            , Link.view "/new" [ localClass [ Link ] ] [ text "Play" ]
            ]
        ]
