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
    games.forEach(function (game) {
      var linkTag = document.createElement('a')
      linkTag.href = '/' + game
      linkTag.className = 'elm-gameroom-link'
      linkTag.innerHTML = game
      rootNode.appendChild(linkTag)
    })
  }
}())
