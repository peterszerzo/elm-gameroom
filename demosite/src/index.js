(function () {
  // This is filled out manually in the dist folder, right before uploading.
  var firebaseConfig = {
    apiKey: '',
    authDomain: '',
    databaseURL: '',
    storageBucket: '',
    messagingSenderId: ''
  }
  var rootNode = document.getElementById('Root')
  var games = [
    'lettero',
    'counterclockwooze',
    'spacecraterball',
    'the-capitalist',
    'fast-and-moebius'
  ]
  var path = window.location.pathname
  var game = games.filter(function (url) {
    return new RegExp('^' + url).test(path.slice(1))
  })[0]
  if (game) {
    var scriptTag = document.createElement('script')
    scriptTag.src = '/' + game + '.js?' + window.__ELM_GAMEROOM_HASH__
    scriptTag.onload = function () {
      var app = window.Elm.Main.embed(rootNode)
      window.talkToPorts(window.db(firebaseConfig, {rootRef: '/' + game}), app.ports)
    }
    document.body.appendChild(scriptTag)
  } else {
    (function () {
      var html =
        '<div class="elm-gameroom-home">' +
        '<svg><use xlink:href="#logo"></use></svg>' +
        '<h1>Play elm-gamerooms</h1>' +
        '<p>Hey, thanks for stopping by. Here are some playables for you and your friends:</p>' +
        games.map(function (game) {
          return '<a class="elm-gameroom-home-link" href="/' + game + '">' + game + '</a>'
        }).join('') +
        '<p>This is a demo for the <a class="elm-gameroom-home-simple-link" href="http://package.elm-lang.org/packages/peterszerzo/elm-gameroom/latest">elm-gameroom</a> project.</p>' +
        '</div>'
      rootNode.innerHTML = html
    }())
  }
}())
