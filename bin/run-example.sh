#!/bin/sh

# Copy JS boilerplate
cat src/js/db/local-storage.js src/js/talk-to-ports.js > examples/$1/app.js

# Start elm-live server
elm-live examples/$1/Main.elm --dir=examples/$1 --output examples/$1/elm.js --debug --open --pushstate
