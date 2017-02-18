module Gameroom.Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Gameroom.Modules.NewRoom.Models as NewRoom
import Gameroom.Modules.Game.Models as Game


type Route problemType guessType
    = Home
    | About
    | Tutorial
    | NewRoomRoute NewRoom.Model
    | Game (Game.Model problemType guessType)
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


defaultRouteUrl : ( Route problemType guessType, String )
defaultRouteUrl =
    ( Home, "" )


matchers : UrlParser.Parser (Route problemType guessType -> a) a
matchers =
    UrlParser.oneOf
        [ s homePath |> map Home
        , s aboutPath |> map About
        , s tutorialPath |> map Tutorial
        , s roomsPath
            </> string
            </> string
            |> map (\roomId playerId -> Game { roomId = roomId, playerId = playerId, room = Nothing, roundTime = 0 })
        , s newRoomPath |> map (NewRoomRoute NewRoom.init)
        ]


parse : Navigation.Location -> Route problemType guessType
parse location =
    location
        |> UrlParser.parsePath matchers
        |> Maybe.withDefault NotFound
