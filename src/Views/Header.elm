module Views.Header exposing (..)

import Html exposing (Html, header, text)
import Messages exposing (Msg(..))
import Views.Logo as Logo
import Views.Link as Link
import Views.Header.Styles exposing (CssClasses(..), localClass)


view : Html (Msg problem guess)
view =
    header [ localClass [ Root ] ]
        [ Link.view "/" [ localClass [ HomeLink ] ] [ Logo.view ]
        ]
