#!/bin/sh

DIST=site/dist
SRC=site/src
EXAMPLES=(spacecraterball counterclockwooze lettero the-capitalist fast-and-moebius)

if [ $1 = "build" ]; then
  rm -rf $DIST
  mkdir $DIST

  cp src/js/talk-to-ports.js $DIST
  cp -r src/js/db $DIST
  cp site/src/index.html $DIST
  cp site/src/index.js $DIST

  elm-make site/src/Main.elm --output $DIST/home.js

  for EXAMPLE in "${EXAMPLES[@]}"
  do
    elm-make examples/$EXAMPLE/Main.elm --output $DIST/$EXAMPLE.js
  done

  echo ""
  echo "---"
  echo "🚧  Important 🚧"
  echo "Add firebase config manually to site/dist/index.js!"
  echo "---"
elif [ $1 = "deploy" ]; then
  cd $DIST
  firebase deploy
elif [ $1 = "run" ]; then
  elm-live $SRC/Main.elm --output $SRC/home.js --dir=$SRC --open --debug --pushstate
else
  echo "Not a valid command. Use either build, deploy or run."
fi
