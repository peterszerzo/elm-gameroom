# elm-gameroom

This is an opinionated framework for multiplayer guessing games. It takes care of the boilerplate for calling game rounds, generating problems and reconciling players, allowing the client to specify only the bits unique to each game, and write fully functional frustraing enternatinment in just about 200 lines of code.

For some context on how it is coming to be, [head here](/talk.md).

## Running the examples

Install elm-live: `npm i -g elm-live`
* lettero: `elm-live ./examples/lettero/Main.elm --dir=./examples/lettero --output examples/lettero/elm.js --open --pushstate --debug`
* spinning shapes: `elm-live ./examples/spinning-shapes/Main.elm --dir=./examples/spinning-shapes --output examples/spinning-shapes/elm.js --open --pushstate --debug`
* capitals: `elm-live ./examples/capitals/Main.elm --dir=./examples/capitals --output examples/capitals/elm.js --open --pushstate --debug`
