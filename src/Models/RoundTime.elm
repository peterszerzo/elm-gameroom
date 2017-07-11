module Models.RoundTime
    exposing
        ( RoundTime
        , init
        , update
        , isRoundJustOver
        , isCooldownJustOver
        , timeSinceNewRound
        )

import Time
import Constants


type RoundTime
    = RoundTime
        { current : Maybe Time.Time
        , atRoundStart : Maybe Time.Time
        }


init : RoundTime
init =
    RoundTime
        { current = Nothing
        , atRoundStart = Nothing
        }


timeSinceNewRound : RoundTime -> Time.Time
timeSinceNewRound (RoundTime roundTime) =
    Maybe.map2
        (\current atRoundStart -> current - atRoundStart)
        roundTime.current
        roundTime.atRoundStart
        |> Maybe.withDefault 0


update : Time.Time -> RoundTime -> RoundTime
update time (RoundTime roundTime) =
    RoundTime
        { roundTime
            | current = Just time
            , atRoundStart = roundTime.atRoundStart |> Maybe.withDefault time |> Just
        }


isJustOverHelper : Time.Time -> RoundTime -> RoundTime -> Bool
isJustOverHelper duration prev current =
    let
        prevSinceRoundStart =
            timeSinceNewRound prev

        currentSinceRoundStart =
            timeSinceNewRound current
    in
        prevSinceRoundStart <= duration && currentSinceRoundStart > duration


isRoundJustOver : RoundTime -> RoundTime -> Bool
isRoundJustOver =
    isJustOverHelper Constants.roundDuration


isCooldownJustOver : RoundTime -> RoundTime -> Bool
isCooldownJustOver =
    isJustOverHelper (Constants.roundDuration + Constants.cooldownDuration)
