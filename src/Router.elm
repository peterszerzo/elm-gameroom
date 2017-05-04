module Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Models.NewRoom as NewRoom
import Models.Game


type Route problem guess
    = Home
    | About
    | NewRoom NewRoom.NewRoom
    | Game (Models.Game.Game problem guess)
    | NotFound


matchers : UrlParser.Parser (Route problem guess -> a) a
matchers =
    UrlParser.oneOf
        [ s "" |> map Home
        , s "about" |> map About
        , s "rooms"
            </> string
            </> string
            |> map (\roomId playerId -> Models.Game.init roomId playerId |> Game)
        , s "new" |> map (NewRoom NewRoom.init)
        ]


parse : Navigation.Location -> Route problem guess
parse location =
    location
        |> UrlParser.parsePath matchers
        |> Maybe.withDefault NotFound
