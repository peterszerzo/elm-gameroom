module Views.Home exposing (..)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (style)
import Messages.Main exposing (Msg(..))
import Views.Styles as Styles
import Views.Link as Link
import Views.Logo as Logo
import Views.Styles as Styles


view : Html (Msg problem guess)
view =
    div [ style Styles.centered ]
        [ div
            [ style
                [ ( "width", "100px" )
                , ( "height", "100px" )
                , ( "margin", "auto" )
                ]
            ]
            [ Logo.view ]
        , h1 [ style Styles.heroType ] [ text "elm-gameroom" ]
        , Link.view "/tutorial" [ style Styles.link ] [ text "Tutorial" ]
        , Link.view "/new" [ style Styles.link ] [ text "New room" ]
        ]
