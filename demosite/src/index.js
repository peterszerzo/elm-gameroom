(function () {
  var HASH = 'a1bcc54'
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
    'thecapitalist'
  ]
  var path = window.location.pathname
  var game = games.filter(function (url) {
    return new RegExp('^' + url).test(path.slice(1))
  })[0]
  if (game) {
    var scriptTag = document.createElement('script')
    scriptTag.src = '/' + game + '.js?' + HASH
    scriptTag.onload = function () {
      var app = window.Elm.Main.embed(rootNode)
      window.talkToPorts(window.db(firebaseConfig, {rootRef: '/' + game}), app.ports)
    }
    document.body.appendChild(scriptTag)
  } else {
    (function () {
      var html =
        '<div class="elm-gameroom-home">' +
        '<h1>elm-gameroom demo</h1>' +
        '<p>Hey, thanks for stopping by. Come play some games with your friends:</p>' +
        games.map(function (game) {
          return '<a class="elm-gameroom-home-link" href="/' + game + '">' + game + '</a>'
        }).join('') +
        '<p>This is a demo for <a href="http://package.elm-lang.org/packages/peterszerzo/elm-gameroom/latest">elm-gameroom</a></p>'
        '</div>'
      rootNode.innerHTML = html
    }())
  }
}())
