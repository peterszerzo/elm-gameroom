# elm-gameroom JavaScript utilities

An Elm app running on `elm-gameroom` needs a thin piece of JavaScript hooked up to a generic backend. This folder provides backend examples, as well as examples on how this backend communicates with the ports the Elm app needs to run.

## db

The `db-**.js` files in this folder describe a promise-based API with methods required to interact with the backend. A simple local-storage polling implementation (useful for local testing), and a Firebase implementation are provided

## talk-to-ports

If your database implementation follows the `db` API, then you can use this piece of code to talk to your Elm ports.
