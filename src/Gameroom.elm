module Gameroom
    exposing
        ( Spec
        , Ports
        , Msg
        , Model
        , basePath
        , name
        , subheading
        , instructions
        , roundDuration
        , cooldownDuration
        , clearWinner
        , responsiblePorts
        , generatorFromList
        , noInlineStyle
        , noPeripheralUi
        , css
        , unicodeIcon
        , game
        , gameWith
        )

{-| This is a framework for creating [multiplayer Guessing games by the boatloads](https://www.youtube.com/watch?v=sBCz6atTRZk), all within the comfort of Elm. Specify only what is unique to a game, write no logic on the back-end, and have it all wired up and ready to play.

`elm-gameroom` takes care of calling game rounds, generating problems and reconciling scores, as well as talking to either a generic real-time database such as Firebase (JS adapter provided), with have clients sort things out amongst themselves via WebRTC (JavaScript glue code provided).

# The main game program
@docs game, gameWith

# Game spec
@docs Spec

Use these `Msg` and `Model` types to annotate your program when using the [game](/Gameroom#game) or [gameWith](/Gameroom#gameWith) methods.
@docs Model, Msg

# Ports
@docs Ports

# Settings
@docs basePath, name, subheading, instructions, unicodeIcon, clearWinner, roundDuration, cooldownDuration, noInlineStyle, noPeripheralUi, responsiblePorts

# Miscellaneous
@docs css

# Utils
@docs generatorFromList
-}

import Window
import Task
import Time
import Navigation
import Random
import Css
import Models
import Data.Ports as Ports
import Subscriptions exposing (subscriptions)
import Messages
import Update exposing (update, cmdOnRouteChange)
import Router
import Data.Route as Route
import Data.Ports as Ports
import Data.Spec as Spec exposing (Setting(..), buildDetailedSpec)
import Views exposing (view)
import Views.Layout


{-| Define the unique bits and pieces to your game, all generalized over a type variable representing a `problem`, and one representing a `guess`. It's going to look a little heavy, but it'll make sense very quickly, I promise. Here it goes:

    type alias Spec problem guess =
        { view : Context guess -> problem -> Html guess
        , evaluate : problem -> guess -> Float
        , problemGenerator : Random.Generator problem
        , problemEncoder : problem -> Encode.Value
        , problemDecoder : Decode.Decoder problem
        , guessEncoder : guess -> Encode.Value
        , guessDecoder : Decode.Decoder guess
        }

* view: The core of the user interface corresponding to the current game round, excluding all navigation, notifications and the score boards. Emits guesses. The first argument is a view context containing peripheral information such as window size, round time, already recorded guesses etc., and it's [documented on its own](/Gameroom-Context). The second, main argument is the current game problem.
* evaluate: given a problem and a guess, returns a numerical evaluation of the guess. The player with the highest evaluation wins a given round. Note that this is affected by the [clearWinner](/Gameroom#clearWinner) setting, which specifies that only by attaining a certain highest evaluation can a player win.
* problemGenerator: a random generator churning out new problems. If your problems are a simple list, there is a [convenient helper](/Gameroom#generatorFromList).
-}
type alias Spec problem guess =
    Spec.Spec problem guess


{-| Msg type alias for the game program.
-}
type alias Msg problem guess =
    Messages.Msg problem guess


{-| Model type alias for the game program.
-}
type alias Model problem guess =
    Models.Model problem guess


{-| The Ports record contains incoming and outgoing ports necessary for a guessing game, like so:

    port outgoing : Json.Encode.Value -> Cmd msg

    port incoming : (Json.Encode.Value -> msg) -> Sub msg

    ports = { incoming = incoming, outgoing = outgoing }
-}
type alias Ports msg =
    Ports.Ports msg


{-| If your game doesn't start at the root route, you need to tell the package so the routing is done correctly, e.g. `basePath "/game1"`. This is useful if you want to host multiple games on the same domain, and have them share data stores. This is how the demo site is set up :).

You can omit the leading slash or have an extra trailing slash. However, base paths with inner slashes such as `/games/game1` are currently not supported.
-}
basePath : String -> Setting problem guess
basePath url =
    BasePath url


{-| Set the duration of the game round (how long players have to make their guesses).
-}
roundDuration : Time.Time -> Setting problem guess
roundDuration duration =
    RoundDuration duration


{-| Set the duration of the cooldown phase after a game round is over.
-}
cooldownDuration : Time.Time -> Setting problem guess
cooldownDuration duration =
    CooldownDuration duration


{-| The name of your game, e.g. `name "YouWillSurelyLose"`.
-}
name : String -> Setting problem guess
name name_ =
    Name name_


{-| A subheading to go under the name on the home page.
-}
subheading : String -> Setting problem guess
subheading subheading_ =
    Subheading subheading_


{-| Instructions displayed in the tutorial section.
-}
instructions : String -> Setting problem guess
instructions instructions_ =
    Instructions instructions_


{-| A unicode icon for your game.
-}
unicodeIcon : String -> Setting problem guess
unicodeIcon icon_ =
    UnicodeIcon icon_


{-| In the most general case, players compete in getting as close as possible to a given goal. However, sometimes you might want to simplify the game and designate winners only if they attained a specific evaluation value specified by `Spec.evaluate`.

If you use the clearWinner setting, make sure `evaluate` does not depend on the timestamp.
-}
clearWinner : Float -> Setting problem guess
clearWinner maxEvaluation =
    ClearWinner maxEvaluation


{-| By default, the game interface renders an inline <style> tag within the Elm app's view. If you want to compile and add the CSS yourself (and add intermediate steps like autoprefixing), use this setting to disable the tag. See [css](/Gameroom#css) for instructions on how to compile the CSS yourself.
-}
noInlineStyle : Setting problem guess
noInlineStyle =
    NoInlineStyle


{-| Do not render any peripheral ui such as scoreboards and game notifications.
-}
noPeripheralUi : Setting problem guess
noPeripheralUi =
    NoPeripheralUi


{-| Handle communication with the outside world through ports.

    port outgoing : Json.Encode.Value -> Cmd msg

    port incoming : (Json.Encode.Value -> msg) -> Sub msg

    main =
      gameWith
        [ responsiblePorts
            { incoming = incoming
            , outgoing = outgoing
            }
        ]
        spec

Why responsible? Because you need to talk to them appropriately. For more details on wiring up ports to a generic backend, see the [JS documentation](/src/js/README.md). Don't worry, it is all razorthin boilerplate.
-}
responsiblePorts : Ports (Msg problem guess) -> Setting problem guess
responsiblePorts ports =
    SetPorts ports


init :
    Spec.DetailedSpec problem guess
    -> Navigation.Location
    -> ( Model problem guess, Cmd (Messages.Msg problem guess) )
init spec loc =
    let
        route =
            Router.parse spec.basePath loc

        cmd =
            Cmd.batch
                [ cmdOnRouteChange spec route Nothing
                , Window.size |> Task.perform Messages.Resize
                , if route == Route.NotOnBaseRoute then
                    Navigation.newUrl spec.basePath
                  else
                    Cmd.none
                ]
    in
        ( { route = route
          , windowSize = Window.Size 0 0
          }
        , cmd
        )


{-| Gives access to the app's elm-css stylesheet, so you can compile it yourself if you like. Note that an inline stylesheet is inserted by default, so if you use the compiled css file, make sure you use the [noInlineStyle](/Gameroom#noInlineStyle) setting.
-}
css : Css.Stylesheet
css =
    Views.Layout.css


{-| Create a generator from a discrete list of problems, the first of which is supplied separately to make sure the list is not empty. For example,

    generatorFromList "apples" [ "oranges", "lemons" ]

creates a generator that yields a random problems the list ["apples", "oranges", "lemons"]. Note that one default item must present by default, in order to still be able to generate an entry when an empty list is passed.
-}
generatorFromList : problem -> List problem -> Random.Generator problem
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


{-| Create a game program from a spec object, using any data type you can dream up for `problem` and `guess`. The [spec](/Gameroom#Spec) is the declarative definition of the basic game logic and views powering your game.

As it is, this program doesn't work in multiplayer. For that, you have to set up outside communication with the back-end of your choice. See [responsiblePorts](/Gameroom#responsiblePorts) for instructions.

Notice you don't have to supply any `init`, `update` or `subscriptions` field yourself. All that is taken care of, and you wind up with a working interface that allows you to create game rooms, invite others, and play. Timers, scoreboards etc. all come straight out of the box.
-}
game :
    Spec problem guess
    -> Program Never (Model problem guess) (Msg problem guess)
game =
    gameWith []


{-| Game program with a list of settings. For example, this program:

    gameWith
        [ name "MyCoolGame"
        , roundDuration (10 * Time.second)
        , cooldownDuration (4 * Time.second)
        , clearWinner 100
        , noPeripheralUi
        ]
        { -- spec object from before
        }

This produces a game with a custom name, custom round duration, custom cooldown duration between rounds, a clear winner at evaluation 100 (meaning no player can win unless their guess evaluates to exactly 100), and disable the peripheral ui - the score board, timer and winner notifications - so you can build those yourself in whichever design you prefer.
-}
gameWith :
    List (Setting problem guess)
    -> Spec problem guess
    -> Program Never (Model problem guess) (Msg problem guess)
gameWith settings spec =
    let
        detailedSpec =
            buildDetailedSpec settings spec
    in
        Navigation.program (Messages.ChangeRoute << (Router.parse detailedSpec.basePath))
            { init = init detailedSpec
            , view = view detailedSpec
            , update = update detailedSpec
            , subscriptions = subscriptions detailedSpec
            }
