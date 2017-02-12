module Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Models.NewRoom
import Models.Game


type Route problemType guessType
    = Home
    | About
    | Tutorial
    | NewRoomRoute Models.NewRoom.NewRoom
    | Game (Models.Game.Game problemType guessType)
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
            |> map (\roomId playerId -> Game { roomId = roomId, playerId = playerId, room = Nothing })
        , s newRoomPath |> map (NewRoomRoute { roomId = "", playerIds = [ "", "" ] })
        ]


parse : Navigation.Location -> Route problemType guessType
parse location =
    location
        |> UrlParser.parsePath matchers
        |> Maybe.withDefault NotFound
