#!/bin/sh

rm -rf tmp
mkdir tmp
cp talk.html tmp/index.html
cp talk.md tmp
surge tmp elm-europe-peterszerzo.surge.sh
