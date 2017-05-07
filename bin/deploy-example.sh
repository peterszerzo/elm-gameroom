#!/bin/sh

# Copy JS boilerplate
cat src/js/db/local-storage.js src/js/talk-to-ports.js > examples/$1/app.js

elm-make examples/$1/Main.elm --output examples/$1/elm.js

cp examples/$1/index.html examples/$1/200.html

surge examples/$1 $2.surge.sh
