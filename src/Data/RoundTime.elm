module Data.RoundTime
    exposing
        ( RoundTime
        , init
        , update
        , justPassed
        , timeSinceNewRound
        )

import Time


type RoundTime
    = RoundTime
        { current : Maybe Time.Time
        , atStart : Maybe Time.Time
        }


init : RoundTime
init =
    RoundTime
        { current = Nothing
        , atStart = Nothing
        }


timeSinceNewRound : RoundTime -> Time.Time
timeSinceNewRound (RoundTime roundTime) =
    Maybe.map2
        (\current atStart -> current - atStart)
        roundTime.current
        roundTime.atStart
        |> Maybe.withDefault 0


update : Time.Time -> RoundTime -> RoundTime
update time (RoundTime roundTime) =
    RoundTime
        { roundTime
            | current = Just time
            , atStart = roundTime.atStart |> Maybe.withDefault time |> Just
        }


justPassed : Time.Time -> RoundTime -> RoundTime -> Bool
justPassed duration prev current =
    let
        prevSinceRoundStart =
            timeSinceNewRound prev

        currentSinceRoundStart =
            timeSinceNewRound current
    in
        prevSinceRoundStart <= duration && currentSinceRoundStart > duration
