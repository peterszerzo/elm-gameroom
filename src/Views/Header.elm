module Views.Header exposing (..)

import Html exposing (Html, header, text)
import Messages exposing (Msg(..))
import Views.Link as Link
import Views.Header.Styles exposing (CssClasses(..), localClass)


view : String -> Html (Msg problem guess)
view icon =
    header [ localClass [ Root ] ]
        [ Link.view "/" [ localClass [ HomeLink ] ] [ text icon ]
        ]
