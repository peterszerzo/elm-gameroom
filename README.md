# 🏓 elm-gameroom

This is a framework for creating multiplayer guessing games. It takes care of calling game rounds, generating problems and reconciling players, as well as talking directly to a generic realtime backend such as Firebase or WebRTC (implementations provided).

With all that out of the way, the client is free to specify only the bits unique to each game, and write fully functional frustrating entertainment in just under 200 lines of code.

For some context on how it is coming to be, [head here](/talk.md).

## Running the examples

Install elm-live: `npm i -g elm-live`

Run the following command: `bin/run-example.sh $NAME`, where `$NAME` is a folder name within `./examples`.
