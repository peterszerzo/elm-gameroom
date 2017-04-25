module Views.Home exposing (..)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (style)
import Html.CssHelpers
import Messages exposing (Msg(..))
import Views.Link as Link
import Views.Logo as Logo
import Styles


{ class } =
    Html.CssHelpers.withNamespace ""


view : Html (Msg problem guess)
view =
    div [ class [ Styles.Centered ] ]
        [ div
            [ style
                [ ( "width", "100px" )
                , ( "height", "100px" )
                , ( "margin", "auto" )
                ]
            ]
            [ Logo.view ]
        , h1 [ class [ Styles.Hero ] ] [ text "elm-gameroom" ]
        , Link.view "/tutorial" [ class [ Styles.Link ] ] [ text "Tutorial" ]
        , Link.view "/new" [ class [ Styles.Link ] ] [ text "New room" ]
        ]
