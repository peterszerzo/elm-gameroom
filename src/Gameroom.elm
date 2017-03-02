module Gameroom exposing (..)

{-| This library creates multiplayer games.

# The game spec
@docs Spec, Ports

# The program
@docs program

# Useful types
@docs Model, Msg

# Utilities
@docs generatorFromList
-}

import Time
import Navigation
import Random
import Gameroom.Models.Spec
import Gameroom.Models.Ports
import Gameroom.Models.Main
import Gameroom.Messages as Messages
import Gameroom.Update exposing (update, cmdOnRouteChange)
import Gameroom.Router as Router
import Gameroom.Views.Main exposing (view)
import Gameroom.Modules.Game.Messages as GameMessages
import Gameroom.Modules.NewRoom.Messages as NewRoomMessages


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
-}
type alias Spec problemType guessType =
    Gameroom.Models.Spec.Spec problemType guessType


{-| Program configuration, including ports
-}
type alias Ports msg =
    Gameroom.Models.Ports.Ports msg


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
    -> Ports (Msg problemType guessType)
    -> Program Never (Model problemType guessType) (Msg problemType guessType)
program spec config =
    Navigation.program (Messages.ChangeRoute << Router.parse)
        { init =
            (\loc ->
                let
                    route =
                        Router.parse loc

                    cmd =
                        cmdOnRouteChange config route Nothing
                in
                    ( { route = route }, cmd )
            )
        , view = view spec
        , update = update spec config
        , subscriptions =
            (\model ->
                Sub.batch
                    [ config.roomUpdated (\val -> Messages.GameMsgC (GameMessages.ReceiveUpdate val))
                    , case model.route of
                        Router.Game _ ->
                            Time.every (20000 * Time.millisecond) (\time -> Messages.GameMsgC (GameMessages.Tick time))

                        Router.NewRoomRoute _ ->
                            config.roomCreated (\msg -> Messages.NewRoomMsgC (NewRoomMessages.CreateResponse msg))

                        _ ->
                            Sub.none
                    ]
            )
        }


{-| Create a generator from a discrete list of problems. For instance,

    generatorFromList "apples" [ "oranges", "lemons" ] == generator yielding random problems from ["apples", "oranges", "lemons"]

We're making your life a little hard having to break off the first member of your list, but it is necessary to make sure the array we end up working with is non-empty. We'd love to generate a funny word like "perrywinkle" to keep the compiler happy, but remember, problems can be of any shape or form, and elm-gameroom is unaware of what that shape or form is.
-}
generatorFromList : problemType -> List problemType -> Random.Generator problemType
generatorFromList first rest =
    let
        list =
            [ first ] ++ rest
    in
        Random.int 0 (List.length list - 1)
            |> Random.map
                (\i ->
                    list
                        |> List.drop i
                        |> List.head
                        |> Maybe.withDefault first
                )
