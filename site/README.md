This folder defines the content of the [demo site](https://elm-gameroom.firebaseapp.io), requiring all kinds of files from the rest of the repository, e.g. example games.

To deploy, make sure you have `uglifyjs` installed: `npm i uglify-js -g`. Then run `./bin/site.sh build` from the repository's root, add firebase credentials manually to the distribution folder (follow instructions from the previous shell script), and run `./bin/site.sh deploy` to deploy.
