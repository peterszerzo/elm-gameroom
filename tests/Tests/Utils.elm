module Tests.Utils exposing (..)

import Test exposing (..)
import Expect
import Utils


tests : Test
tests =
    describe "Utils"
        [ describe "template"
            [ test "replaces value if ${} is present" <|
                \() ->
                    Utils.template "Hi, my name is ${}." "Peter"
                        |> Expect.equal "Hi, my name is Peter."
            , test "returns original template if ${} is not present" <|
                \() ->
                    Utils.template "Hi, my name is ${." "Peter"
                        |> Expect.equal "Hi, my name is ${."
            ]
        ]
