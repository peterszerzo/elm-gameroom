const functions = require('firebase-functions')

const cors = require('cors')({origin: true})

exports.test = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    res.status(200).send('Hello, World!')
  })
})
