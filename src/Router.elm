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
    | NotOnBaseRoute
    | NotFound


startsWithBase : Maybe String -> String -> Bool
startsWithBase baseSlug path_ =
    case baseSlug of
        Nothing ->
            True

        Just baseSlug ->
            (String.left ((String.length baseSlug) + 1) path_) == ("/" ++ baseSlug)


sWithBaseSlug : Maybe String -> String -> Parser a a
sWithBaseSlug baseSlug slug =
    case baseSlug of
        Just baseSlug ->
            if slug == "" then
                s baseSlug
            else
                s baseSlug </> s slug

        Nothing ->
            s slug


matchers : Maybe String -> UrlParser.Parser (Route problem guess -> a) a
matchers baseSlug =
    let
        s_ =
            sWithBaseSlug baseSlug
    in
        UrlParser.oneOf
            [ s_ "" |> map Home
            , s_ "about" |> map About
            , s_ "tutorial" |> map (Tutorial Models.Tutorial.init)
            , s_ "rooms"
                </> string
                </> string
                |> map (\roomId playerId -> Models.Game.init roomId playerId |> Game)
            , s_ "new" |> map (NewRoom Models.NewRoom.init)
            ]


parse : Maybe String -> Navigation.Location -> Route problem guess
parse baseSlug location =
    if startsWithBase baseSlug location.pathname then
        location
            |> UrlParser.parsePath (matchers baseSlug)
            |> Maybe.withDefault NotFound
    else
        NotOnBaseRoute
