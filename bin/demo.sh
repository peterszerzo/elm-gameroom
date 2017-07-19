#!/bin/sh

ROOT=site
DIST=dist
SRC=src
LIBSRC=../src
EXAMPLES=(spacecraterball counterclockwooze lettero the-capitalist fast-and-moebius)

if [ $1 = "build" ]; then
  cd $ROOT
  rm -rf $DIST
  mkdir $DIST

  cp $LIBSRC/js/talk-to-ports.js $DIST
  cp -r $LIBSRC/js/db $DIST
  cp $SRC/index.html $DIST
  cp $SRC/index.js $DIST

  elm-make src/Main.elm --output $DIST/home.js

  for EXAMPLE in "${EXAMPLES[@]}"
  do
    elm-make ../examples/$EXAMPLE/Main.elm --output $DIST/$EXAMPLE.js
  done

  echo ""
  echo "---"
  echo "🚧  Important 🚧"
  echo "Add firebase config manually to site/dist/index.js!"
  echo "---"
elif [ $1 = "deploy" ]; then
  cd $ROOT
  firebase deploy
elif [ $1 = "run" ]; then
  cd $ROOT
  elm-live $SRC/Main.elm --output $SRC/home.js --dir=$SRC --open --debug --pushstate
else
  echo "Not a valid command. Use either build, deploy or run."
fi
