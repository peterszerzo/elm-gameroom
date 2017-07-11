module Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Models.NewRoom
import Models.Game
import Models.Tutorial


type Route problem guess
    = Home
    | NewRoom Models.NewRoom.NewRoom
    | Tutorial (Models.Tutorial.Tutorial problem guess)
    | Game (Models.Game.Game problem guess)
    | NotOnBaseRoute
    | NotFound


startsWithBase : String -> String -> Bool
startsWithBase basePath path_ =
    String.left (String.length basePath) path_ == basePath


sWithBaseSlug : String -> String -> Parser a a
sWithBaseSlug basePath slug =
    let
        baseSlug =
            String.dropLeft 1 basePath
    in
        if baseSlug == "" then
            s slug
        else
            (if slug == "" then
                s baseSlug
             else
                s baseSlug </> s slug
            )


matchers : String -> UrlParser.Parser (Route problem guess -> a) a
matchers basePath =
    let
        s_ =
            sWithBaseSlug basePath
    in
        UrlParser.oneOf
            [ s_ "" |> map Home
            , s_ "tutorial" |> map (Tutorial Models.Tutorial.init)
            , s_ "rooms"
                </> string
                </> string
                |> map (\roomId playerId -> Models.Game.init roomId playerId |> Game)
            , s_ "new" |> map (NewRoom Models.NewRoom.init)
            ]


parse : String -> Navigation.Location -> Route problem guess
parse basePath location =
    if startsWithBase basePath location.pathname then
        location
            |> UrlParser.parsePath (matchers basePath)
            |> Maybe.withDefault NotFound
    else
        NotOnBaseRoute
