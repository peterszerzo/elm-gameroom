module Constants exposing (..)

-- Miscellaneous


nullString : String
nullString =
    -- If a value (room data, player data) doesn't exist in storage, this string is inserted instead. This is necessary because some storage services like Firebase are weird with non-existent values while retrieving data.
    "__elm-gameroom__null__"



-- Copy


correctGuessCopy : String
correctGuessCopy =
    "Correct - let's see if you made it the fastest.."


incorrectGuessCopy : String
incorrectGuessCopy =
    "Not quite, not quite unfortunately.."


evaluatedGuessCopy : String
evaluatedGuessCopy =
    "This is scoring you a ${}. Let's see how the others are doing.."


winCopy : String
winCopy =
    "Nice job, you win!"


loseCopy : String
loseCopy =
    "This one goes to ${}. Go get them in the next round!"


tieCopy : String
tieCopy =
    "It's a tie, folks, it's a tie.."


tutorialStartupCopy : String
tutorialStartupCopy =
    "Hey, let's practice. Click the button to get a game problem you can solve."


tutorialEvaluatedGuessCopy : String
tutorialEvaluatedGuessCopy =
    "This one will score you a ${}. Can you do better?"


newRoomPageTitle : String
newRoomPageTitle =
    "Game on!"


newRoomFormIntroCopy : String
newRoomFormIntroCopy =
    "But first, some forms.. In order to play with your friends, use this form to create your very own room. You’ll then be able to share links unique to each player, control when you feel ready, and be on your way!"


casualNamesWarningCopy : String
casualNamesWarningCopy =
    "We took the liberty to make your names casual and URL-friendly for your convenience :)."
