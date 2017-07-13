#!/bin/sh

# Copy JS boilerplate
cp -r src/js/db examples/$1
cp src/js/talk-to-ports.js examples/$1

# Start elm-live server
elm-live examples/$1/Main.elm --dir=examples/$1 --output examples/$1/elm.js --debug --open --pushstate
