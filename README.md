# elm-gameroom

This is an opinionated framework for multiplayer guessing games. It takes care of the boilerplate for calling game rounds, generating problems and reconciling players, allowing the client to specify only the bits unique to each game, and write fully functional frustraing enternatinment in just about 200 lines of code.

For some context on how it is coming to be, [head here](/talk.md).

## Running the examples

Install elm-live: `npm i -g elm-live`

Run the following command: `bin/run-example.sh $NAME`, where `$NAME` is a folder name within `./examples`.
