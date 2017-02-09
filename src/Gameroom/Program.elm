module Program exposing (..)

import Html
import Models exposing (Spec)
import Messages exposing (Msg(..))
import Update exposing (update)
import Ports
import Views exposing (view)


program :
    Spec problemType guessType
    -> Program Never (Models.Model problemType guessType) (Msg guessType)
program spec =
    Html.program
        { init = ( { playerId = "alfred", room = Nothing }, Cmd.none )
        , view = view spec
        , update = update spec
        , subscriptions =
            (\model -> Ports.updated ReceiveUpdate)
        }
