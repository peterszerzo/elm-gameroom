;(function () {
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
    var scriptTag = document.createElement('script')
    scriptTag.src = '/home.js?' + window.__ELM_GAMEROOM_HASH__
    scriptTag.onload = function () {
      console.log(games)
      var app = window.Elm.Main.embed(rootNode, games)
    }
    document.body.appendChild(scriptTag)
  }
}())
