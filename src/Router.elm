module Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Models.NewRoom
import Models.Game
import Models.Tutorial


type Route problem guess
    = Home
    | About
    | NewRoom Models.NewRoom.NewRoom
    | Tutorial (Models.Tutorial.Tutorial problem guess)
    | Game (Models.Game.Game problem guess)
    | NotFound


matchers : UrlParser.Parser (Route problem guess -> a) a
matchers =
    UrlParser.oneOf
        [ s "" |> map Home
        , s "about" |> map About
        , s "tutorial" |> map (Tutorial Models.Tutorial.init)
        , s "rooms"
            </> string
            </> string
            |> map (\roomId playerId -> Models.Game.init roomId playerId |> Game)
        , s "new" |> map (NewRoom Models.NewRoom.init)
        ]


parse : Navigation.Location -> Route problem guess
parse location =
    location
        |> UrlParser.parsePath matchers
        |> Maybe.withDefault NotFound
