module Views.Header exposing (view)

import Html exposing (Html, header, text)
import Html.CssHelpers
import Messages exposing (Msg(..))
import Views.Logo as Logo
import Views.Link as Link
import Styles


{ class, classList } =
    Html.CssHelpers.withNamespace ""


view : Html (Msg problem guess)
view =
    header [ class [ Styles.Header ] ]
        [ Link.view "/" [ class [ Styles.HeaderHomeLink ] ] [ Logo.view ]
        ]
