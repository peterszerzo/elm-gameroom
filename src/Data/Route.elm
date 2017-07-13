module Data.Route exposing (..)

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
