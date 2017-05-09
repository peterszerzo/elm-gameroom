#!/bin/sh

DIST=demosite/dist
EXAMPLES=(spacecraterball counterclockwooze lettero thecapitalist)

rm -rf $DIST
mkdir $DIST

cp src/js/talk-to-ports.js $DIST
cp src/js/db/firebase.js $DIST/db-firebase.js
cp demosite/src/index.html $DIST
cp demosite/src/index.js $DIST
cp demosite/src/index.css $DIST

for EXAMPLE in "${EXAMPLES[@]}"
do
  elm-make examples/$EXAMPLE/Main.elm --output $DIST/$EXAMPLE.js
done

echo ""
echo "---"
echo "🚧  Important 🚧"
echo "Add firebase config manually to demosite/dist/index.js!"
echo "---"
