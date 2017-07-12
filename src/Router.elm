module Router exposing (..)

import Navigation
import UrlParser exposing (..)
import Page.NewRoom.Models
import Page.Game.Models
import Page.Tutorial.Models


type Route problem guess
    = Home
    | NewRoom Page.NewRoom.Models.Model
    | Tutorial (Page.Tutorial.Models.Model problem guess)
    | Game (Page.Game.Models.Model problem guess)
    | NotOnBaseRoute
    | NotFound


startsWithBase : String -> String -> Bool
startsWithBase basePath path_ =
    String.left (String.length basePath) path_ == basePath


sWithBasePath : String -> String -> Parser a a
sWithBasePath basePath slug =
    -- Redefines UrlParser's 's' function to take into account a base path.
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
            sWithBasePath basePath
    in
        UrlParser.oneOf
            [ s_ "" |> map Home
            , s_ "tutorial" |> map (Tutorial Page.Tutorial.Models.init)
            , s_ "rooms"
                </> string
                </> string
                |> map
                    (\roomId playerId ->
                        Page.Game.Models.init roomId playerId
                            |> Game
                    )
            , s_ "new" |> map (NewRoom Page.NewRoom.Models.init)
            ]


parse : String -> Navigation.Location -> Route problem guess
parse basePath location =
    if startsWithBase basePath location.pathname then
        location
            |> UrlParser.parsePath (matchers basePath)
            |> Maybe.withDefault NotFound
    else
        NotOnBaseRoute
