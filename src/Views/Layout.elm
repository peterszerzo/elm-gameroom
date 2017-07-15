module Views.Layout exposing (view, css)

import Html exposing (Html, div, node, p, a, text)
import Html.CssHelpers
import Css exposing (Stylesheet, stylesheet, position, fixed, top, px, bottom, left, right, backgroundColor, hex)
import Css.Namespace exposing (namespace)
import Css.File exposing (compile)
import Messages
import Views.Attribution
import Views.Attribution.Styles
import Views.Footer.Styles
import Views.Header
import Views.Header.Styles
import Views.Notification.Styles
import Views.Scoreboard.Styles
import Views.Timer.Styles
import Page.Game.Views.Styles
import Page.Home.Views.Styles
import Page.NewRoom.Views.Styles
import Page.NotFound.Views.Styles
import Page.Tutorial.Views.Styles
import Styles.Shared
import Styles.Constants exposing (white)


type CssClasses
    = Root


cssNamespace : String
cssNamespace =
    "layout"


styles : List Css.Snippet
styles =
    [ Css.class Root
        [ position fixed
        , top (px 0)
        , bottom (px 0)
        , left (px 0)
        , right (px 0)
        , Css.displayFlex
        , Css.alignItems Css.center
        , Css.justifyContent Css.center
        , backgroundColor (hex white)
        ]
    ]
        |> namespace cssNamespace


css : Stylesheet
css =
    stylesheet
        (Styles.Shared.styles
            ++ styles
            ++ Views.Attribution.Styles.styles
            ++ Views.Footer.Styles.styles
            ++ Views.Header.Styles.styles
            ++ Views.Notification.Styles.styles
            ++ Views.Scoreboard.Styles.styles
            ++ Views.Timer.Styles.styles
            ++ Page.Game.Views.Styles.styles
            ++ Page.Home.Views.Styles.styles
            ++ Page.NewRoom.Views.Styles.styles
            ++ Page.NotFound.Views.Styles.styles
            ++ Page.Tutorial.Views.Styles.styles
        )


class : List class -> Html.Attribute msg
class =
    Html.CssHelpers.withNamespace cssNamespace |> .class


view : Bool -> Bool -> String -> List (Html (Messages.Msg problem guess)) -> Html (Messages.Msg problem guess)
view renderInlineStyle showAttribution icon children =
    div
        [ class [ Root ]
        ]
    <|
        (if renderInlineStyle then
            [ node "style" [] [ compile [ css ] |> .css |> text ] ]
         else
            []
        )
            ++ (if showAttribution then
                    [ Views.Attribution.view ]
                else
                    [ Views.Header.view icon
                    ]
               )
            ++ children
