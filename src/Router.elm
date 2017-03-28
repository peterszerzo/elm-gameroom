module Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Models.NewRoom as NewRoom
import Models.Game as Game


type Route problem guess
    = Home
    | About
    | Tutorial
    | NewRoom NewRoom.NewRoom
    | Game (Game.Game problem guess)
    | NotFound


tutorialPath : String
tutorialPath =
    "tutorial"


aboutPath : String
aboutPath =
    "about"


newRoomPath : String
newRoomPath =
    "new"


homePath : String
homePath =
    ""


roomsPath : String
roomsPath =
    "rooms"


defaultRouteUrl : ( Route problem guess, String )
defaultRouteUrl =
    ( Home, "" )


matchers : UrlParser.Parser (Route problem guess -> a) a
matchers =
    UrlParser.oneOf
        [ s homePath |> map Home
        , s aboutPath |> map About
        , s tutorialPath |> map Tutorial
        , s roomsPath
            </> string
            </> string
            |> map (\roomId playerId -> Game { roomId = roomId, playerId = playerId, room = Nothing, roundTime = 0 })
        , s newRoomPath |> map (NewRoom NewRoom.init)
        ]


parse : Navigation.Location -> Route problem guess
parse location =
    location
        |> UrlParser.parsePath matchers
        |> Maybe.withDefault NotFound
