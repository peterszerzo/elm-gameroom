#!/bin/sh

# Copy JS boilerplate
cp -r src/js/db examples/$1
cp src/js/talk-to-ports.js examples/$1

# Start elm-live server
cd examples/$1
elm-live Main.elm --dir=. --output elm.js --debug --open --pushstate
