module Gameroom exposing (..)

{-| This library creates multiplayer games.

# The game spec
@docs Spec

# The program
@docs program

# Useful types
@docs Model, Msg
-}

import Time
import Navigation
import Gameroom.Models.Spec
import Gameroom.Models.Main
import Gameroom.Messages as Messages
import Gameroom.Update.Main exposing (update, cmdOnRouteChange)
import Gameroom.Ports as Ports
import Gameroom.Router as Router
import Gameroom.Views.Main exposing (view)


{-| Define every moving part of a multiplayer game:

    type alias Spec problemType guessType =
        { view : ... -> Html.Html guessType
        , isGuessCorrect : problemType -> guessType -> Bool
        , problemGenerator : Random.Generator problemType
        , problemEncoder : Maybe problemType -> JE.Value
        , problemDecoder : JD.Decoder (Maybe problemType)
        , guessEncoder : guessType -> JE.Value
        , guessDecoder : JD.Decoder guessType
        }

Isn't that all we need?
-}
type alias Spec problemType guessType =
    Gameroom.Models.Spec.Spec problemType guessType


{-| Use this Msg type to annotate your program.
-}
type alias Msg problemType guessType =
    Messages.Msg problemType guessType


{-| Use this Model type to annotate your program.
-}
type alias Model problemType guessType =
    Gameroom.Models.Main.Model problemType guessType


{-| Create the game program. No intricately wired up inits, updates or views to be passed in here, just a Spec.

Appropriate ports must be wired up. Docs for that are coming soon!
-}
program :
    Spec problemType guessType
    -> Program Never (Model problemType guessType) (Msg problemType guessType)
program spec =
    Navigation.program (Messages.ChangeRoute << Router.parse)
        { init =
            (\loc ->
                let
                    route =
                        Router.parse loc

                    cmd =
                        cmdOnRouteChange route Nothing
                in
                    ( { route = route }, cmd )
            )
        , view = view spec
        , update = update spec
        , subscriptions =
            (\model ->
                Sub.batch
                    [ Ports.roomUpdated Messages.ReceiveGameRoomUpdate
                    , case model.route of
                        Router.Game _ ->
                            Time.every (50 * Time.millisecond) (\t -> Messages.GameMsgContainer (Messages.Tick t))

                        _ ->
                            Sub.none
                    ]
            )
        }
